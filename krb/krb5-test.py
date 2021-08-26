#!/usr/bin/env python
#pip install requests requests-kerberos

import requests
from requests_kerberos import HTTPKerberosAuth

kerberos_auth = HTTPKerberosAuth(force_preemptive=True)
r = requests.get( "https://goto/jupyter", auth=kerberos_auth )

print(r.content)
