vcl 4.0;
# List of upstream proxies we trust to set X-Forwarded-For correctly.
acl upstream_proxy {
     "127.0.0.1";
}

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

sub vcl_recv {
    # Set the X-Forwarded-For header so the backend can see the original
    # IP address. If one is already set by an upstream proxy, we'll just re-use that.
    if (client.ip ~ upstream_proxy && req.http.X-Forwarded-For) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For;
    } else {
        set req.http.X-Forwarded-For = regsub(client.ip, ":.*", "");
    }
}

sub vcl_hash {
    # URL and hostname/IP are the default components of the vcl_hash
    # implementation. We add more below.
    hash_data(req.url);
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }

    # Include the X-Forward-Proto header, since we want to treat HTTPS
    # requests differently, and make sure this header is always passed
    # properly to the backend server.
    if (req.http.X-Forwarded-Proto) {
        hash_data(req.http.X-Forwarded-Proto);
    }
    #return (hash);
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    set beresp.ttl = 60s;
}
