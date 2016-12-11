add them to service.json

[Examples: type of checks](https://www.consul.io/docs/agent/checks.html)

```
{
  "service": {
    "name": "service_name",
    "port": "80",
    "check":[ 
    {    
      "http": "http://localhost:8080",
      "interval": "10s"                    
    },
    {
        ... another check
    }
    ]
  }
}
```