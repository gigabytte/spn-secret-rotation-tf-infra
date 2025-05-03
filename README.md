# Azure SPN Secret Rotation - Infrastructure

An event-driven, scalable solution for automated rotation of Azure Service Principal secrets stored in Key Vault.

## Problem Statement

Build a centralized, scalable, and low-maintenance system to rotate Entra ID Service Principal client secrets, integrated with Azure Key Vault across thousands of SPNs, with minimal administrative overhead.

[Related Medium Article series](https://medium.com/@gregbrooks3393/fixing-the-unscalable-how-we-built-an-azure-tenant-wide-spn-secret-rotation-system-part-1-f85fbd88231c)

## Why Not Terraform?

1. **Terraform Is Declarative, Not Procedural**
   - Terraform's design is to declare desired state, not to manage secret rotation workflows
   - Secrets rotation is a procedural, event-driven process
   - Risk of leaving "stale" or orphaned secrets if Terraform run fails
   - Requires admin run the pipeline before secret expiration

2. **Security Risks in CI/CD**
   - Storing SPN credentials in CI/CD requires elevated permissions
   - Risk of credential leakage through pipeline logs
   - Potential pipeline lockout if rotation fails

3. **Self-Destructive Behavior**
   - Rotating the secret for the running SPN invalidates its session
   - Can leave system in unrecoverable state

4. **State Management Issues**
   - Secrets stored in plaintext in Terraform state
   - Unnecessary secret recreation on each run

## Why Not Batch Processing?

1. **No Context-Aware Rotation**
   - Ignores individual SPN expiration dates
   - Risk of missing critical rotations

2. **Increased Operational Complexity**
   - Requires maintaining separate database
   - Additional infrastructure to manage
   - Risk of data mistakes

3. **Data Drift Issues**
   - Database becomes stale source of truth
   - Lacks real-time validation

## Why Event-Driven?

1. **Just-in-Time Rotation**
   - Secrets rotated only when needed
   - Avoids unnecessary churn
   - Stays within compliance windows

2. **Real-Time Responsiveness**
   - Immediate reaction to Key Vault events
   - Proactive handling of expiring secrets

3. **Enhanced Security**
   - Uses Managed Identities
   - No secrets in CI/CD
   - Safe rotation pattern: generate → store → validate → disable old → notify

4. **Scalability**
   - Each function handles one event/SPN
   - Avoids API rate limits
   - Isolated failure domains

5. **Built-in Resilience**
   - Automatic retry mechanisms
   - Error handling
   - Alerting capabilities

## Architecture Components

- Azure Key Vault: Stores SPN secrets and emits audit logs
- Log Analytics Workspace: Centralizes audit logs and enables monitoring
- Azure Monitor: Queries for expiring secrets and generates alerts
- Event Hub: Handles alert events for secret rotation
- Azure Functions: Processes events and performs secret rotation
- Managed Identities: Secures access between components

## Repository Structure

```
├── platform/              # Core infrastructure components
│   ├── function_apps.tf   # Azure Functions configuration
│   ├── eventhub.tf       # Event Hub setup
│   ├── monitor.tf        # Azure Monitor and alerts
│   └── networking.tf     # Network security configuration
│
└── customer/             # Customer-specific resources
    ├── keyvault.tf      # Key Vault configuration
    ├── kv_secrets.tf    # Secret management
    └── spn.tf           # Service Principal setup
```

## Prerequisites

- Azure Subscription
- Terraform 1.0+
- Azure CLI
- Appropriate Azure AD permissions

## Deployment

1. Configure platform infrastructure:
```bash
cd platform
terraform init
terraform plan
terraform apply
```

2. Deploy customer resources:
```bash
cd ../customer
terraform init
terraform plan
terraform apply
```

## Security Considerations

- NSG implementation recommended
- Use Private Endpoints/Private Link where possible
- Implement fine-grained RBAC for Managed Identities
- Configure resource firewalls to prevent public internet exposure

## Contributing

Contributions are welcome! Submit pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.