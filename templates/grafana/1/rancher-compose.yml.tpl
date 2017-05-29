.catalog:
  name: "Grafana"
  version: "4.3.1-rancher1"
  description: |
      Grafana: Beautiful metric & analytic dashboards
  questions:
    - variable: http_protocol
      description: "Protocol to access Grafana"
      label: "Protocol"
      required: true
      default: "http"
      type: "enum"
      options:
        - http
        - https
    - variable: http_port
      description: "Exposed port to access Grafana"
      label: "Port"
      required: true
      default: "80"
      type: "int"
    - variable: http_host
      description: "Name to publish Grafana"
      label: "Publish ame"
      required: true
      default: "grafana.demo"
      type: "string"
    - variable: ssl_cert
      description: "ssl certificate. Mandatory if Protocol = https"
      label: "SSL cert"
      required: false
      default: ""
      type: "certificate"
    - variable: admin_username
      description: "Grafana admin username"
      label: "Admin Username"
      required: true
      default: "admin"
      type: "string"
    - variable: admin_password
      description: "Grafana admin password"
      label: "Admin Password"
      required: true
      default: "password"
      type: "string"
    - variable: secret_key
      description: "Signing secret key"
      label: "Secret Key"
      required: true
      default: "su2Tong2zoocie"
      type: "string"
    - variable: default_role
      description: "Default role to new users"
      label: "Default user role"
      required: true
      default: "Admin"
      type: "enum"
      options:
        - Admin
        - Editor
        - Read Only Editor
    - variable: extra_params
      description: "Grafana extra params"
      label: "Extra params"
      required: false
      type: "multiline"
      default: |
        GF_AUTH_GITHUB_ENABLED: 'true'
        GF_AUTH_GITHUB_AUTH_URL: https://github.com/login/oauth/authorize
        GF_AUTH_GITHUB_TOKEN_URL: https://github.com/login/oauth/access_token
        GF_AUTH_GITHUB_API_URL: https://api.github.com/user
        GF_AUTH_GITHUB_SCOPES: user:email,read:org
        GF_AUTH_GITHUB_CLIENT_ID: 66bc59b220441546801d
        GF_AUTH_GITHUB_CLIENT_SECRET: 954bbcddb6a4902fa1e4f0fee418ff6dbbd30d7e
        GF_AUTH_GITHUB_ALLOWED_ORGANIZATIONS: rancher
        GF_AUTH_GITHUB_ALLOW_SIGN_UP: 'true'
version: '2'
services:
  grafana:
    scale: 1
    start_on_create: true
    metadata:
      grafana:
        params: |
          ${extra_params}
  grafana-lb:
    scale: 1
    start_on_create: true
    lb_config:
      {{- if (.Values.ssl_cert) }}
      certs: []
      default_cert: ${ssl_cert}
      {{- end}}
      port_rules:
      - priority: 1
        protocol: ${http_protocol}
        service: grafana
        source_port: ${http_port}
        target_port: 3000
    health_check:
      healthy_threshold: 2
      response_timeout: 2000
      port: 42
      unhealthy_threshold: 3
      initializing_timeout: 60000
      interval: 2000
      reinitializing_timeout: 60000