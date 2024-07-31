# Infraestructura como Código de Página web de React + Vite.

Créditos: Damian Colaneri

## ¿Cómo implementarlo en mi proyecto de React + Vite?

En principio este repositorio es funcional en Gitlab. 
En tu cuenta de Gitlab creá un repositorio.

Creá las siguientes variables de CI/CD:
- AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY: Credenciales IAM de AWS (esto es para la correcta ejecución de los scripts de Terraform con AWS CLI).
- JUANKEYS: (Puede llevar otro nombre siempre que después se cambie el nombre en los scripts de .gitlab-ci.yml donde se nombra esta variable) Esta variable llevará el valor de un par de claves que tengamos creadas en AWS, el cual después indicaremos en la configuración de la instancia EC2 en main.tf.
- TF_API_TOKEN: Token de acceso personal; ir a User Settings > Access Tokens > Generar un token con permisos "api" y "read_repository" (copiar el token, ya que solo se muestra una vez). Ese token será el valor de esta variable.

Después personalizá los siguientes valores en la iac terraform:
- En main.tf: como valor de subnet_id en la instancia ec2 poné el valor del id de una subnet existente en AWS que esté asociada a una vpc existente. Como valor de key_name en la instancia ec2 poné el nombre de tu par de calves de AWS. Después en "connection" donde dice "private_key = file("./juankeys.pem")" reemplazar "juankeys" con el nombre de tu par de claves de AWS. Después en el grupo de seguridad reemplazar el id de la vpc con una vpc existente en AWS que esté asociada a la subnet especificada anteriormmente.
- en provider.tf: debemos modificar los valores de las direcciones de backend en backend "http"{...}, según el ID de nuestro proyecto de GitLab (Repositorio de GitLab > Settings > General > Project ID). Una vez lo tengamos, en los valores de address, lock_address y unlock_address, reemplazamos por nuestro ID en esos valores de la siguiente manera donde dice "ProjectID"; https://gitlab.com/api/v4/projects/ProjectID/terraform/...

Después queda por último la personalización del pipeline:
En los stages deploy y destroy, reemplazamos cuando se nombra a "juankeys.pem" con el nombre de nuestras llaves + .pem (si son .pem) y también cuando se nombra a "$JUANKEYS" reemplazamos JUANKEYS con el nombre de nuestra variable del entorno CI/CD que tenga el valor de nuestro par de claves de AWS.

Después de esto, siempre que se haga un commit, se ejecutará el pipeline, que levantará la infraestructura de AWS con Terraform al mismo tiempo que se vincula el proyecto con la instancia EC2. El stage destroy es manual, por lo que se recomienda ejecutar el stage de destroy antes de pushear un nuevo commit. Después del stage de deploy ejecutado correctamente, se podrá acceder a la instancia EC2 mediante el navegador por la dirección DNS pública de la instancia EC2 en cuestión, la cual se puede encontrar en el detalle de la instancia EC2 creada (en consolo de EC2 en AWS), esta dirección tiene una sintaxis algo así: "ec2-54-91-21-6.compute-1.amazonaws.com"

---

### English: 

To implement Infrastructure as Code (IaC) for a React + Vite project using Terraform and GitLab CI/CD, follow the detailed steps below. This includes setting up CI/CD variables, customizing Terraform files, and adjusting the GitLab pipeline.

### 1. Create a Repository on GitLab
Create a repository in your GitLab account to host your React + Vite project and the IaC configuration files.

### 2. Set Up CI/CD Variables in GitLab
Go to your GitLab repository settings and add the following variables in the CI/CD section:

- **AWS_ACCESS_KEY_ID**: Your AWS IAM access key.
- **AWS_SECRET_ACCESS_KEY**: Your AWS IAM secret key.
- **JUANKEYS**: This name can be changed according to your preferences, but it must match what is used in the GitLab CI/CD scripts. This variable contains the value of an AWS key pair that you will use to access your EC2 instance.
- **TF_API_TOKEN**: A personal access token from GitLab with "api" and "read_repository" permissions. It can be generated in `User Settings > Access Tokens`.

### 3. Customize Terraform Files
#### `main.tf` File
In this file, you need to customize several values:

- **subnet_id**: Specify the ID of an existing subnet in AWS associated with an existing VPC.
- **key_name**: Specify the name of your AWS key pair.
- **connection**: Change `private_key = file("./juankeys.pem")` to the name of your key file, for example, `private_key = file("./mykey.pem")`.
- **Security Group**: Replace the VPC ID with an existing VPC in AWS associated with the specified subnet.

#### `provider.tf` File
Modify the backend addresses to match your GitLab project ID. You can find your Project ID in `GitLab Repository > Settings > General > Project ID`. Replace the fields `address`, `lock_address`, and `unlock_address` with the URL corresponding to your project ID, for example:
```hcl
backend "http" {
  address        = "https://gitlab.com/api/v4/projects/ProjectID/terraform/state"
  lock_address   = "https://gitlab.com/api/v4/projects/ProjectID/terraform/lock"
  unlock_address = "https://gitlab.com/api/v4/projects/ProjectID/terraform/unlock"
}
```

### 4. Customize the GitLab CI/CD Pipeline
In the `.gitlab-ci.yml` file, make the following changes:

- In the `deploy` and `destroy` stages, replace all references to "juankeys.pem" with the name of your key file, for example, "mykey.pem".
- Also, ensure that when the environment variable `$JUANKEYS` is mentioned, it matches the name of the variable you set in GitLab.

### 5. Run the Pipeline
Every time you commit, the GitLab pipeline will automatically run, creating the AWS infrastructure with Terraform. The `destroy` stage is manual, and it is recommended to execute it before pushing a new commit to avoid conflicts.

### 6. Access the EC2 Instance
Once the `deploy` stage runs successfully, you can access your React + Vite application on the EC2 instance through its public DNS address. This address can be found in the instance details in the AWS EC2 console.

Example of a public DNS address: `ec2-54-91-21-6.compute-1.amazonaws.com`.

Following these steps should enable you to set up and deploy your React + Vite application using Terraform and GitLab CI/CD!
