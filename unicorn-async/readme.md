# Unicorn with Async

This example demonstrates how to use Unicorn with the Async gem to handle HTTP requests with asynchronous capabilities.

## Echoing a large amount of data

```
$ dd if=/dev/random bs=1M count=1 2>/dev/null | curl -X POST -H "Content-Type: application/octet-stream" --data-binary @- http://localhost:9292 --output echoed.bin
```

## Drip feeding requests

Install `pv` if not available.

### For a simple GET request (drip-feed the headers)

```
echo -e "GET / HTTP/1.1\r\nHost: localhost:9292\r\nConnection: close\r\n\r\n" | pv -L 1 | nc localhost 9292
```

### For a POST request with data

```
{
  echo -e "POST / HTTP/1.1\r\nContent-Length: 100\r\nHost: localhost:9292\r\n\r\n"
  yes "a" | head -100 | tr -d '\n'
} | pv -L 1 | nc localhost 9292
```

## Notes on errors

Unicorn writes a slightly different response when `RACK_ENV=none` is set.

### Example output without `RACK_ENV=none`:

#### Client

```
> curl -v http://localhost:8080
* Host localhost:8080 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8080...
* connect to ::1 port 8080 from ::1 port 52822 failed: Connection refused
*   Trying 127.0.0.1:8080...
* Connected to localhost (127.0.0.1) port 8080
* using HTTP/1.x
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/8.10.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Tue, 17 Jun 2025 03:22:41 GMT
< Connection: close
< content-type: text/plain
< content-length: 13
< 
* shutting down connection #0
Hello, World!⏎
```

#### Server

```
[pid 585643] accept4(7, {sa_family=AF_INET, sin_port=htons(57686), sin_addr=inet_addr("127.0.0.1")}, [128 => 16], SOCK_CLOEXEC) = 6
[pid 585643] recvfrom(6, "GET / HTTP/1.1\r\nHost: localhost:"..., 16384, MSG_DONTWAIT, NULL, NULL) = 40
[pid 585643] write(6, "HTTP/1.1 200 OK\r\nDate: Tue, 17 J"..., 121) = 121
[pid 585643] write(6, "Hello, World!", 13) = 13
[pid 585643] shutdown(6, SHUT_RDWR)     = 0
[pid 585643] close(6)                   = 0
```

#### Original `wrk`

```
> wrk -d1 http://localhost:8080
Running 1s test @ http://localhost:8080
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     8.64ms    3.43ms  31.98ms   85.50%
    Req/Sec   576.10    132.04   707.00     80.00%
  1149 requests in 1.00s, 150.36KB read
Requests/sec:   1146.52
Transfer/sec:    150.03KB
```

Note that no errors are reported.

### Example output with `RACK_ENV=none`:

#### Client

```
> curl -v http://localhost:8080
* Host localhost:8080 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:8080...
* connect to ::1 port 8080 from ::1 port 47984 failed: Connection refused
*   Trying 127.0.0.1:8080...
* Connected to localhost (127.0.0.1) port 8080
* using HTTP/1.x
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/8.10.1
> Accept: */*
> 
* Request completely sent off
< HTTP/1.1 200 OK
< Date: Tue, 17 Jun 2025 03:23:36 GMT
< Connection: close
< content-type: text/plain
< 
* shutting down connection #0
Hello, World!⏎
```

#### Server

The `content-length` header is not present (note the response size is 101 bytes instead of 121 bytes).

```
[pid 585506] accept4(7, {sa_family=AF_INET, sin_port=htons(34378), sin_addr=inet_addr("127.0.0.1")}, [128 => 16], SOCK_CLOEXEC) = 6
[pid 585506] recvfrom(6, "GET / HTTP/1.1\r\nHost: localhost:"..., 16384, MSG_DONTWAIT, NULL, NULL) = 40
[pid 585506] write(6, "HTTP/1.1 200 OK\r\nDate: Tue, 17 J"..., 101) = 101
[pid 585506] write(6, "Hello, World!", 13) = 13
[pid 585506] shutdown(6, SHUT_RDWR)     = 0
[pid 585506] close(6)                   = 0
```

#### Original `wrk`

```
> wrk -d1 http://localhost:8080
Running 1s test @ http://localhost:8080
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.56ms    5.11ms  29.14ms   71.54%
    Req/Sec   384.25    107.54   620.00     65.00%
  767 requests in 1.01s, 85.71KB read
  Socket errors: connect 0, read 767, write 0, timeout 0
Requests/sec:    763.07
Transfer/sec:     85.27KB
```
