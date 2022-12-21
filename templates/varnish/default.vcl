#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide for a comprehensive documentation
# at https://www.varnish-cache.org/docs/.

# Marker to tell the VCL compiler that this VCL has been written with the
# 4.0 or 4.1 syntax.
vcl 4.1;
#import std;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "VARNISH_HOST";
    .port = "8080";
}


acl purge {
    "localhost";
    "VARNISH_PURGE_HOST"/24;
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # Purge cache
    if (req.method == "PURGE") {
        if (!client.ip ~purge) {
            return (synth(405, "Not allowed."));
        }
        return (purge);
    }
    # Add an X-Forwarded-For header with the client IP address.
    if (req.restarts == 0) {
        if (req.http.X-Forwarded-For) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    # Only handle relevant HTTP request methods
    if (
        req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "PATCH" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE"
    ) {
        return (pipe);
    }

    # Remove tracking query string parameters used by analytics tools
    if (req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=") {
        set req.url = regsuball(req.url, "&(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "");
        set req.url = regsuball(req.url, "\?(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "?");
        set req.url = regsub(req.url, "\?&", "?");
        set req.url = regsub(req.url, "\?$", "");
    }

    # Only cache GET and HEAD requests
    if ((req.method != "GET" && req.method != "HEAD") || req.http.Authorization) {
        return(pass);
    }

    # Mark static files with the X-Static-File header, and remove any cookies
    # X-Static-File is also used in vcl_backend_response to identify static files
    if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        set req.http.X-Static-File = "true";
        unset req.http.Cookie;
        return(hash);
    }

    # Don't cache the following pages
#    if (req.url ~ "^/status.php$" ||
#        req.url ~ "^/update.php$" ||
#        req.url ~ "^/cron.php$" ||
#        req.url ~ "^/admin$" ||
#        req.url ~ "^/admin/.*$" ||
#        req.url ~ "^/flag/.*$" ||
#        req.url ~ "^.*/ajax/.*$" ||
#        req.url ~ "^.*/ahah/.*$") {
#        return (pass);
#    }

    # Remove all cookies except the session & NO_CACHE cookies
    if (req.http.Cookie) {
        set req.http.Cookie = ";" + req.http.Cookie;
        set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
        set req.http.Cookie = regsuball(req.http.Cookie, ";(S?SESS[a-z0-9]+|NO_CACHE)=", "; \1=");
        set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
        set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

        if (req.http.cookie ~ "^\s*$") {
            unset req.http.cookie;
        } else {
            return(pass);
        }
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.


    # Inject URL & Host header into the object for asynchronous banning purposes
    set beresp.http.x-url = bereq.url;
    set beresp.http.x-host = bereq.http.host;

    # Serve stale content for 2 minutes after object expiration
    # Perform asynchronous revalidation while stale content is served
    set beresp.grace = 120s;

    # If the file is marked as static we cache it for 1 day
    if (bereq.http.X-Static-File == "true") {
        unset beresp.http.Set-Cookie;
        set beresp.ttl = 1d;
    }

    # If we dont get a Cache-Control header from the backend
    # we default to 1h cache for all objects
    if (!beresp.http.Cache-Control) {
        set beresp.ttl = 1h;
    }

    # Parse Edge Side Include tags when the Surrogate-Control header contains ESI/1.0
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        set beresp.do_esi = true;
    }

    if (bereq.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset beresp.http.Set-Cookie;
        set beresp.ttl = 1d;
    }



    set beresp.http.X-Content-Type-Options = "nosniff";
    set beresp.http.X-XSS-Protection = "1; mode=block";
    set beresp.http.Strict-Transport-Security = "max-age=31536000; includeSubDomains; preload";
    set beresp.http.Content-Security-Policy = "default-src 'self' *.DOMAIN_NAME; script-src 'self' *.DOMAIN_NAME";
    set beresp.http.X-Permitted-Cross-Domain-Policies = "none";
    set beresp.http.Referrer-Policy = "strict-origin";
    # set beresp.http.Feature-Policy = \""camera: 'none'; vr: 'none'; microphone: 'none';  payment: 'none'; midi: 'none'; microphone: 'none'\""
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # Cleanup of headers
    unset resp.http.x-url;
    unset resp.http.x-host;
    unset req.http.X-Static-File;
    unset resp.http.X-Varnish;
    unset resp.http.Via;
    unset resp.http.Age;
    unset resp.http.Server;
}
