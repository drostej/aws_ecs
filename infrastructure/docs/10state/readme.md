Vorbereitung:
- In der Konsole, zunächst wie es sich für sensible Systeme gehört, MFA konfigurieren
- Access Keys Anlegen und in dem Credemtoaös ablegen

Artikel:
https://devopscube.com/setup-terraform-remote-state-s3-dynamodb/

### Konfiguration dieser...
- Empfohlen für die Arbeit mit der AWS CLI ist ein SSO token provider https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

- Aus dem AWS Account, unter security credentials,key_id und aws_secret_key kopieren.
- Anzulegen sind 

***~/.aws/config:***

```
[profile tefde-sandbox]
```

***~/.aws/credentials:***
```
[tefde-sandbox]
aws_access_key_id = AKIAW3SM6FC72LNDHYDL
aws_secret_access_key = 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
```

![state 20241014113645.png](20241014113645.png)]


Um einen state (Vergelich mit Konflikten in git) für alle effektiv einzusetzten, wird im ASS eine DynamoDB Tabelle (Wer blockt den state?) 
und ein S3 bucket mit dem state selbst angelegt. Dieser kann im Landingzone sehr lang sein.


Der Terraform workflow ist der folgene:
- ***main.tf*** oder andere Dateien anlegen
- Mit ***terraform init*** wird das Verzeichnis initialisiert ---> vergeich git init
- Der Terraform state/lock wird dann der erste Schritt, der auf die Umgebung des Profils zugreift ***aws-vault exec pond-sandbox -- terraform apply***
- Sind die unter apply gelisteten Änderungen wie geplant und erwartet, setzt man die Änderungen um ***aws-vault exec pond-sandbox -- terraform apply***
- Mit ***terraform destroy*** löscht man die Instanz


Vorbereitung:
- In der Konsole, zunächst wie es sich für sensible Systeme gehört, MFA konfigurieren
- Access Keys Anlegen und in dem Credemtoaös ablegen
- Herausfinden wie das vpc heisst, das AWS automatisch anlegt, durch nachschauen in der Konsole oder die Konsolenversion:
- ``` aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0],CidrBlock]' --output table```








## Schritte auf der Konsole:

Das kann in die .bashrc eingetragen werden, wenn man nur ein AWS Profil nutzt.
 ```export AWS_PROFILE=tefde-sandbox```


cd infrastructure/terraform
terraform init

Beim ersten Versuch ist hier zu erwearten, dass der bucket nicht existiert. Ein Henne/Ei Problem.
````
Initializing the backend...
╷
│ Error: Error inspecting states in the "local" backend:
│     S3 bucket does not exist.
│
│ The referenced S3 bucket must have been previously created. If the S3 bucket
│ was created within the last minute, please wait for a minute or two and try
│ again.
│
│ Error: operation error S3: ListObjectsV2, https response error StatusCode: 404, RequestID: M96RGTRME5AKGQRQ, HostID: hgM5AZsQ2nnLAD8y6Qg2SEs0tWw+dtSroo1RLV2NaTdvMTKcP9hQaTfSsxfR4BxH4oOtuXtODnALQVoBsVVaqXlGhWSYRrKV2noaYM+9ldE=, NoSuchBucket:
│
│
│ Prior to changing backends, OpenTofu inspects the source and destination
│ states to determine what kind of migration steps need to be taken, if any.
│ OpenTofu failed to load the states. The data in both the source and the
│ destination remain unmodified. Please resolve the above error and try again.
│
```

terraform apply

# Migration nach dem ersten apply
terraform init -migrate-state

Troubleshooging:
Eventuell wiederspenstige Resourcen in der Webkonsole oder mit der CLI löschen. 


rm -f terraform.tfstate terraform.tfstate.backup
tofu init
tofu apply