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
