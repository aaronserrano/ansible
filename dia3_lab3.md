# Dia 3 - Laboratorio 3

El objetivo de este laboratorio es familiarizarse con el funcionamiento del inventario dinámico.

Por un lado se verá como funciona un proveedor de inventario dinámico "sencillo" como es el de
vagrant. Por la naturaleza de la mezcla vagrant+ansible solo podrán ejecutar esta parte los 
alumnos que trabajen con un SO Unix/Linux. Recomendamos que esta parte se haga siguiendo al instructor
y se enfoque más en entender como se configura un inventario dinámico que en hacer la tarea.

En una segunda parte se configurará el inventario dinámico contra AWS, esta parte si que podrá ser realizada
por todos los alumnos independientemente de que sistema operativo usen.

# Parte 1: Inventario de máquinas vagrant

Tomaremos como referencia el script https://github.com/ansible/ansible/blob/devel/contrib/inventory/vagrant.py

En nuestro PC local, en una carpeta vacía, dejaremos el siguiente fichero con el nombre Vagrantfile

```ruby
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the same key for each machine
  config.ssh.insert_key = false

  config.vm.define "vagrant1" do |vagrant1|
    vagrant1.vm.box = "ubuntu/trusty64"
    vagrant1.vm.network "forwarded_port", guest: 80, host: 8080
    vagrant1.vm.network "forwarded_port", guest: 443, host: 8443
  end
  config.vm.define "vagrant2" do |vagrant2|
    vagrant2.vm.box = "ubuntu/trusty64"
    vagrant2.vm.network "forwarded_port", guest: 80, host: 8081
    vagrant2.vm.network "forwarded_port", guest: 443, host: 8444
  end
  config.vm.define "vagrant3" do |vagrant3|
    vagrant3.vm.box = "ubuntu/trusty64"
    vagrant3.vm.network "forwarded_port", guest: 80, host: 8082
    vagrant3.vm.network "forwarded_port", guest: 443, host: 8445
  end
end
```

Este vagrant file abrirá 3 VMs basadas en ubuntu, la levantaremos con el comando ```vagrant up```

Una vez arrancadas las tres máquinas, ejecutaremos ```vagrant ssh-config``` para ver la información de IP y puerto de
las 3:

```text
| => vagrant ssh-config
Host vagrant1
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/jordimolina/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
  LogLevel FATAL

Host vagrant2
  HostName 127.0.0.1
  User vagrant
  Port 2200
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/jordimolina/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
  LogLevel FATAL

Host vagrant3
  HostName 127.0.0.1
  User vagrant
  Port 2201
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/jordimolina/.vagrant.d/insecure_private_key
  IdentitiesOnly yes
  LogLevel FATAL
```
Ahora podríamos crear un inventario manual parecido al siguiente:
```text
vagrant1 ansible_host=127.0.0.1 ansible_port=2222
vagrant2 ansible_host=127.0.0.1 ansible_port=2200
vagrant3 ansible_host=127.0.0.1 ansible_port=2201

[all:vars]
ansible_private_key_file = /Users/jordimolina/.vagrant.d/insecure_private_key
```

y podríamos trabajar con las 3 vm's, pero vamos a hacerlo de forma automática con un inventario dinámico:

Descargamos en el directorio del vagrant file el script de inventario dinámico mediante vagrant (seremos ordenados y 
lo pondremos en el subdirectorio "inventories")

```bash
mkdir inventories
cd inventories
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/vagrant.py
chmod +x vagrant.py
cd ..
```

Ahora, antes de usarlo con ansible, probaremos el script:

**Si ejecutamos sin parámetros**
```text
| => inventories/vagrant.py 
Usage: vagrant.py [options] --list | --host <machine>

Options:
  -h, --help   show this help message and exit
  --list       Produce a JSON consumable grouping of Vagrant servers for
               Ansible
  --host=HOST  Generate additional host specific details for given host for
               Ansible
```

**Si sacamos la lista con --list**
```json
{"vagrant": ["vagrant1", "vagrant3", "vagrant2"], "_meta": {"hostvars": {
"vagrant1": {"ansible_ssh_host": "127.0.0.1", "ansible_ssh_port": "2222", "ansible_ssh_user": "vagrant", 
"ansible_ssh_private_key_file": "/Users/jordimolina/.vagrant.d/insecure_private_key"}, 
"vagrant3": {"ansible_ssh_host": "127.0.0.1", "ansible_ssh_port": "2201", "ansible_ssh_user": "vagrant", 
"ansible_ssh_private_key_file": "/Users/jordimolina/.vagrant.d/insecure_private_key"}, 
"vagrant2": {"ansible_ssh_host": "127.0.0.1", "ansible_ssh_port": "2200", "ansible_ssh_user": "vagrant", 
"ansible_ssh_private_key_file": "/Users/jordimolina/.vagrant.d/insecure_private_key"}}}}
```

Vemos que:
- para cada VM tiene:
  - Un nombre
  - una ip (con la variable ansible_ssh_host)
  - un puerto (con la variable ansible_ssh_port)
  - un usuario (con la variable ansible_ssh_user)
  
**Si sacamos los valores de una sola máquina (p.e. --host=vagrant1)**
```json
{"ansible_ssh_host": "127.0.0.1", "ansible_ssh_port": "2222", "ansible_ssh_user": "vagrant", 
"ansible_ssh_private_key_file": "/Users/jordimolina/.vagrant.d/insecure_private_key"}
```

Vemos que la primera lista con los hosts no aparece.

Este formato de salida es el que especifica Ansible que debe generar un inventario dinámico. Ésto es importante, si no
se cumple este formato, Ansible no entenderá al inventario dinámico.

**Probar ansible contra el inventario dinámico**

Vamos a hacer una ejecución del siguiente playbook (os será familiar), que dejaremos en el directorio donde está el 
Vagrantfile con el nombre "playbook-nginx.yml".

```yaml
- name: instala y arranca nginx en ubuntu
  hosts: vagrant
  become: True
  tasks:
    - name: instalar nginx
      apt:
        name: nginx
        state: present
        
    - name: arrancar nginx
      service:
        name: nginx
        state: started
        enabled: True
```

Y lo ejecutaremos con

```text
ansible-playbook -i inventories/vagrant.py playbook-nginx.yml
```

Observad como el playbook tarda más de lo habitual en arrancar. Eso es porque ejecuta el script para obtener el 
inventario. Evidentemente este script es más lento que un fichero de texto.


Acabaremos el laboratorio parando las máquinas de vagrant con ```vagrant destroy```


# Parte 2: Inventario de elementos en el cloud de AWS

Este ejercicio puede y debe seguirse por todos los alumnos. Configuraremos en la vagrant que se ha usado durante
todo el curso el inventario dinámico contra la cuenta de AWS en la que se crean los laboratorios.

**Nota:** algunas de las configuraciones de este inventario dinámico son complejas y solo comprensibles con
conocimiento de como funciona el cloud de AWS. No os preocupéis si hay algún concepto que no os queda claro.
A modo de glosario especificamos:
- EC2 : servicio de máquinas virtuales de AWS
- RDS : servicio de bases de datos como servicio de AWS
- ElastiCache : servicio de instancias de caché (redis o memcache) como servicio de AWS
- secret/key par : conjunto de clave y palabra secreta que se utilizan para acceder a la API de AWS
- region : zona geográfica que se usa de AWS (en el curso estamos usando Irlanda, reperesentada por eu-west-1)

Lo primero es asegurarse de que existen máquinas arrancadas en AWS. Para ello lanzaremos el siguiente comando:

```text
ansible-playbook crear-lab-1vm.yml
```

Seguido, descargaremos el script ec2.py (inventario dinámico de AWS) y su fichero de configuración. Lo dejaremos en el 
directorio inventories:

```text
cd inventories/
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini
wget https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
chmod +x ec2.py 
```

Ahora, tenemos que configurar las credenciales de Amazon para el script de inventario dinámico. Para ello tomaremos
nota de las variables aws_secret y aws_access que hay 
en el fichero env_vars/aws_vault.yml

```text
[root@localhost ansible-devops]# cat env_vars/aws_vault.yml 
aws_vpc: "vpc-9c4906fb"
aws_access: "xxxxxxxxxxx"
aws_secret: "yyyyyyyyyyyy"
aws_keypair_name: "curso-itnow"
aws_ec2_ami: "ami-5448952d"
aws_ec2_subnet: "subnet-6399db2a"
```

Y añadiremos estas variables al final del fichero ```inventories/ec2.ini```:

```text
[root@localhost ansible-devops]# tail inventories/ec2.ini 
# way as you would a private SSH key.
#
# Unlike the boto and AWS configure files, this section does not support
# profiles.
#
# aws_access_key_id = AXXXXXXXXXXXXXX
# aws_secret_access_key = XXXXXXXXXXXXXXXXXXX
# aws_security_token = XXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_access_key_id = xxxxxxxxxxx
aws_secret_access_key = yyyyyyyyyyyy
```

También pondremos los siguientes valores en el fichero ```inventories/ec2.ini```:
 
 ```text
regions = eu-west-1 #para limitar la busqueda a IRLANDA
```

```text
rds = False #para evitar indexar servicio RDS
```

```text
elasticache = False #para evitar indexar servicio elasticache
```
Para validar que funciona, ejecutaremos ```inventories/ec2.py --list```

Veremos que:
- La salida es enorme: esto es porque crea grupos basándose en varios parámetros de EC2
  - security groups
  - nombre
  - tags
  - tipo de instancia
  - vpc
  - clave ssh
  - ...

Es infinitamente más complejo que el de vagrant

Si lo ejecutamos de nuevo , veremos que va más rápido, esto es porque hace una caché y hasta que no caduca, no vuevle 
a preguntar a AWS si han habido cambios.

**Aplicar playbook a todas las máquinas que tengan el tag "curso ansible"**

Crearemos una copia de nuestro playbook favorito:

```text
cp d1l1_configurar_nginx.yml lab-dinámico-aws.yml
```

Y modificaremos los grupos a los que se aplica la instalación de nginx por "tag_Curso_ansible"

Y lo ejecutaremos:
```ansible-playbook -i inventories/ec2.py lab-dinámico-aws.yml```

Fallará miserablemente.

**¿Por qué?**

Si os fijáis en el json que ha salido al hacer la lista de máquinas, las máquinas no tienen ningún atributo que
especifique ni el usuario de ssh ni la clave a usar.

Para solucionarlo podemos pasar más parámetros al comando ansible-playbook (que para una vez ya está bien), o podemos
utilizar el **fichero de configuración de ansible**.

En la raíz del repositorio hay un fichero que ha pasado desapercibido, hasta ahora, es el ```ansible.cfg```

Este fichero contiene configuración que queremos que sea por defecto para los comandos de ansible.

Puede estar en ```/etc/ansible``` o en el directorio donde se ejecuten los playbooks.

Vamos a editarlo y dejarlo como sigue:

```text
[defaults]
host_key_checking = False
remote_user = centos
private_key_file = /root/curso-itnow.pem
```

Y volveremos a ejecutar el playbook (ojo, ejecutadlo escalonadamente porque todos váis a lanzar el playbook en las 
máquinas de todos ;) )

```ansible-playbook -i inventories/ec2.py lab-dinámico-aws.yml```

**Recomendado:** Ver la lista de variables del fichero ansible.cfg en 
http://docs.ansible.com/ansible/latest/intro_configuration.html


# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Como funciona el inventario dinámico
- Configurar ansible para el uso de un inventario dinámico
- Como funciona el fichero ansible.cfg y para que sirve

