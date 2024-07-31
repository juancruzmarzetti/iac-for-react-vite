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

Para implementar la infraestructura como código (IaC) para un proyecto de React + Vite utilizando Terraform y GitLab CI/CD, sigue los pasos detallados a continuación. Esto incluye la configuración de las variables de CI/CD, la personalización de archivos Terraform, y el ajuste del pipeline de GitLab.

### 1. Crear un Repositorio en GitLab
Crea un repositorio en tu cuenta de GitLab donde alojarás tu proyecto de React + Vite y los archivos de configuración de IaC.

### 2. Configurar Variables de CI/CD en GitLab
Ve a las configuraciones de tu repositorio en GitLab y agrega las siguientes variables en la sección CI/CD:

- **AWS_ACCESS_KEY_ID**: Tu clave de acceso IAM de AWS.
- **AWS_SECRET_ACCESS_KEY**: Tu clave secreta IAM de AWS.
- **JUANKEYS**: Este nombre puede cambiarse según tus preferencias, pero debe coincidir con lo que se use en los scripts de GitLab CI/CD. Esta variable contiene el valor de un par de claves de AWS que usarás para acceder a tu instancia EC2.
- **TF_API_TOKEN**: Un token de acceso personal de GitLab con permisos "api" y "read_repository". Se puede generar en `User Settings > Access Tokens`.

### 3. Personalizar Archivos de Terraform
#### Archivo `main.tf`
En este archivo, debes personalizar varios valores:

- **subnet_id**: Especifica el ID de una subnet existente en AWS que esté asociada a una VPC existente.
- **key_name**: Especifica el nombre de tu par de claves de AWS.
- **connection**: Cambia `private_key = file("./juankeys.pem")` por el nombre de tu archivo de claves, por ejemplo, `private_key = file("./miarchivo.pem")`.
- **Security Group**: Reemplaza el ID de la VPC con una VPC existente en AWS que esté asociada a la subnet especificada.

#### Archivo `provider.tf`
Modifica las direcciones del backend para que correspondan al ID de tu proyecto de GitLab. Puedes encontrar tu Project ID en `Repositorio de GitLab > Settings > General > Project ID`. Reemplaza en los campos `address`, `lock_address`, y `unlock_address` con la URL correspondiente a tu ID de proyecto, por ejemplo:
```hcl
backend "http" {
  address        = "https://gitlab.com/api/v4/projects/ProjectID/terraform/state"
  lock_address   = "https://gitlab.com/api/v4/projects/ProjectID/terraform/lock"
  unlock_address = "https://gitlab.com/api/v4/projects/ProjectID/terraform/unlock"
}
```

### 4. Personalizar el Pipeline de GitLab CI/CD
En el archivo `.gitlab-ci.yml`, debes hacer las siguientes modificaciones:

- En los stages `deploy` y `destroy`, reemplaza todas las referencias a "juankeys.pem" con el nombre de tu archivo de claves, por ejemplo, "miarchivo.pem".
- También, asegúrate de que cuando se mencione la variable de entorno `$JUANKEYS`, esta coincida con el nombre de la variable que configuraste en GitLab.

### 5. Ejecutar el Pipeline
Cada vez que hagas un commit, el pipeline de GitLab se ejecutará automáticamente, creando la infraestructura de AWS con Terraform. El stage `destroy` es manual, y se recomienda ejecutarlo antes de realizar un nuevo commit para evitar conflictos.

### 6. Acceder a la Instancia EC2
Una vez que el stage de `deploy` se ejecute correctamente, podrás acceder a tu aplicación React + Vite en la instancia EC2 a través de su dirección DNS pública. Esta dirección se puede encontrar en los detalles de la instancia en la consola de EC2 de AWS.

Ejemplo de una dirección DNS pública: `ec2-54-91-21-6.compute-1.amazonaws.com`.

¡Con estos pasos, deberías poder configurar y desplegar tu aplicación de React + Vite usando Terraform y GitLab CI/CD!
