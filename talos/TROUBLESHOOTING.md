# Minikube

```
Test-NetConnection -ComputerName $(minikube ip) -Port 80 -Information Detailed
```

# Traefik VALUES for websecure
| Name | Default | Notes |  
|------|---------|-------|
| ports.websecure.allowACMEByPass | bool | false | See upstream documentation |
|ports.websecure.appProtocol|	string|	nil|	See upstream documentation|
ports.websecure.containerPort	string	nil	
ports.websecure.expose.default	bool	true	
ports.websecure.exposedPort	int	443	
ports.websecure.forwardedHeaders.insecure	bool	false	
ports.websecure.forwardedHeaders.notAppendXForwardedFor	bool	false	Disable appending RemoteAddr to X-Forwarded-For header (v3.7+).
ports.websecure.forwardedHeaders.trustedIPs	list	[]	Trust forwarded headers information (X-Forwarded-*).
ports.websecure.hostPort	string	nil	
ports.websecure.http.encodedCharacters	object	nil	See upstream documentation
ports.websecure.http.maxHeaderBytes	string	nil	Maximum size of request headers in bytes. Default: 1048576 (1 MB)
ports.websecure.http.middlewares	list	[]	See upstream documentation
ports.websecure.http.sanitizePath	string	nil	See upstream documentation
ports.websecure.http.tls.certResolver	string	""	
ports.websecure.http.tls.domains	list	[]	
ports.websecure.http.tls.enabled	bool	true	See upstream documentation
ports.websecure.http.tls.options	string	""	
ports.websecure.http3.advertisedPort	string	nil	
ports.websecure.http3.enabled	bool	false	
ports.websecure.nodePort	string	nil	See upstream documentation
ports.websecure.observability.accessLogs	string	nil	Enables access-logs for this entryPoint.
ports.websecure.observability.metrics	string	nil	Enables metrics for this entryPoint.
ports.websecure.observability.traceVerbosity	string	nil	Defines the tracing verbosity level for this entryPoint.
ports.websecure.observability.tracing	string	nil	Enables tracing for this entryPoint.
ports.websecure.port	int	8443	
ports.websecure.protocol	string	"TCP"	
ports.websecure.proxyProtocol.insecure	bool	false	
ports.websecure.proxyProtocol.trustedIPs	list	[]	Enable the Proxy Protocol header parsing for the entry point
ports.websecure.targetPort	string	nil	
ports.websecure.transport.keepAliveMaxRequests	string	nil	
ports.websecure.transport.keepAliveMaxTime	string	nil	
ports.websecure.transport.lifeCycle.graceTimeOut	string	nil	
ports.websecure.transport.lifeCycle.requestAcceptGraceTimeout	string	nil	
ports.websecure.transport.respondingTimeouts.idleTimeout	string	nil	
ports.websecure.transport.respondingTimeouts.readTimeout	string	nil	
ports.websecure.transport.respondingTimeouts.writeTimeout	string	nil
```