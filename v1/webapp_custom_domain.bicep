param location string
param hostingPlanId string
param appServiceName string
param customDomain string

var deploymentId = take(uniqueString(deployment().name), 3)

@description('App Service Managed Certificates for apex domains are validated with HTTP token validation. For more information see https://azure.github.io/AppService/2021/03/02/asmc-apex-domain.html.')
param useHttpToken bool = false

resource appService_hostNameBindings 'Microsoft.Web/sites/hostNameBindings@2020-12-01' = {
  name: '${appServiceName}/${customDomain}'
}

var properties = union({
  serverFarmId: hostingPlanId
  canonicalName: customDomain
}, useHttpToken ? {
  domainValidationMethod: 'http-token'
} : {})

resource appService_certificate 'Microsoft.Web/certificates@2020-12-01' = {
  dependsOn: [
    appService_hostNameBindings
  ]
  name: customDomain
  location: location
  properties: properties
}

module appService_certBinding './__intenal/cert_binding.bicep' = {
  dependsOn: [
    appService_certificate
  ]
  name: '${deploymentId}_${appServiceName}-certBinding'
  params: {
    name: '${appServiceName}/${customDomain}'
    certificateThumbprint: appService_certificate.properties.thumbprint
  }
}
