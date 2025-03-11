// Import the set of Radius resources (Applications.*) into Bicep
extension radius

@description('The Radius environment to deploy the application to.')
param environment string

@description('The number of replicas to deploy.')
param replicas string

// Define the environment ID
var envId = '/planes/radius/local/resourcegroups/default/providers/Applications.Core/environments/${environment}'

resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'app'
  properties: {
    environment: envId
  }
}

resource demo 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'demo'
  properties: {
    application: app.id
    container: {
      image: 'ghcr.io/radius-project/samples/demo:latest'
      ports: {
        web: {
          containerPort: 3000
        }
      }
    }
    connections: {
      redis: {
        source: db.id
      }
    }
    extensions: [
      {
        kind: 'manualScaling'
        replicas: int(replicas)
      }
    ]
  }
}

resource db 'Applications.Datastores/redisCaches@2023-10-01-preview' = {
  name: 'db'
  properties: {
    application: app.id
    environment: envId
  }
}
