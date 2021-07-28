param name string
@secure()
param certificateThumbprint string

resource hostNameBindings 'Microsoft.Web/sites/hostNameBindings@2020-12-01' = {
  name: name
  properties: {
    sslState: 'SniEnabled'
    thumbprint: certificateThumbprint
  }
}
