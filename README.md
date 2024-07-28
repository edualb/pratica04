# Sumário
- Setup
- Prática
- Evidências

# Setup

## Github

Crie uma conta no Github (https://github.com) e um novo Repositório. 

## Azure

Em terminal, execute o comando abaixo para criar as credenciais da Azure. Precisa `az` cli instalado (https://learn.microsoft.com/pt-pt/cli/azure/install-azure-cli):
```sh
$ az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/20000000-0000-0000-0000-000000000000"
```

Output:
```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

## Github Secrets && .env

Para fazer **testes locais**, você tem a opção de criar um arquivo `.env` e adicionar os seguintes dados:

```sh
export ARM_CLIENT_ID="<appId> do output da AZURE realizado no passo anterior"
export ARM_CLIENT_SECRET="<password> do output da AZURE realizado no passo anterior"
export ARM_SUBSCRIPTION_ID="<subscription> da URL da AZURE"
export ARM_TENANT_ID="<tenant> do output da AZURE realizado no passo anterior"
export TF_VAR_VM_ADMIN_PASSWORD="a senha que você quiser para acessar a VM"
```

Para provisionar a infraestrutura utilizando **CI/CD (Github Actions)**, é preciso configurar diretamente na página do Github acessando: 

`Repositório Github > Settings > Secrets and variables > Actions > New repository secrets`

# Prática

## Criando Servidores (Terraform local)

Para testar antes de enviar para o Github Actions, você pode executar o terraform localmente. Será gerado um arquivo `os/inventory.ini` para ser utilizado no Ansible futuramente.

1. source do envrionment
```sh
$ source .env
```

2. Terraform init
```sh
$ cd infra
$ terraform init
```

3. Terraform plan
```sh
$ terraform plan -out=main.tfplan
```

4. Terraform apply
```sh
$ terraform apply "main.tfplan"
```

## Configurando Servidores (Ansible local)

Com o arquivo `os/inventory.ini` gerado pelo passo anterior, podemos dar continuidade na configuração do Servidor utilizando Ansible:

1. Install dependencies (sshpass):
```sh
$ sudo apt update
$ sudo apt install sshpass
```

2. Configure os servidores:
```sh
$ cd os
$ ansible-playbook -i inventory.ini playbook.yaml
```