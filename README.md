DNS Example
===========

Examples for the [DNS](https://github.com/Bouke/DNS) library.

[![Build Status](https://travis-ci.org/Bouke/DNS-Example.svg?branch=master)](https://travis-ci.org/Bouke/DNS-Example)

## Usage

```
$ swift build
$ .build/debug/dns-client 192.168.0.1 apple.com.

;; Got answer:
;; ->>HEADER<<- opcode: query, status: NOERROR, id: 8437
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;apple.com.                     IN      A

;; ANSWERS SECTION:
apple.com.              2937    IN      A       17.172.224.47
apple.com.              2937    IN      A       17.178.96.59
apple.com.              2937    IN      A       17.142.160.59

;; Query time: 4 msec
;; SERVER: 10.0.1.1:53
;; WHEN: 2017-05-31 19:44:41 +0000
;; MSG SIZE  rcvd: 75
```

## Credits

This example was written by [Bouke Haarsma](https://twitter.com/BoukeHaarsma).
