# Dia 4 - Laboratorio 1

## Importancia del testing en CI/CD

Tal y como se ha comentado durante la clase, es muy importante para la filosofia DevOps
el integrar los mecanismos de testeo automático del código en el propio repositorio.

Es por ello que casi todos los sistemas de CI/CD permiten poner ficheros descriptivos de 
como se ejecutarán los tests de forma que puedan ser fácilmente identificables. Estos 
ficheros suelen situarse en la raíz del repositorio de código que se quiere integrar. 
Algunos ejemplos son:

- TravisCI -> .travis.yml
- Test Kitchen -> .kitchen.yml
- GitlabCI -> .gitlab-ci.yml
- Jenkins -> Jenkinsfile

Algunos de estos sistemas de CI permiten la implementación de pipelines (Travis, Gitlab, 
Jenkins), y otros facilitan saber como y en de que modo se han de ejecutar los tests.

## Test Kitchen

Para nuestro laboratario, prepararemos un rol Ansible para que pueda ser probado en diferentes
versiones de sistema operativo, en entornos aislados, mediante integración con Docker.

Test Kitchen no es un producto de Ansible, es un producto que sale de Chef, pero aún así ha ganado
mucha base de usuarios porque permite integrar diferentes módulos de provisioning (Docker, Vagrant,
AWS, GCE, Azure...), otros módulos de configuración (Chef, Ansible, Puppet) y motores de testing
(InSpec, ServerSpec, RSpec, Bats)

La configuración que usaremos como concepto para nuestro laboratorio será:
- Test Kitchen
- Docker para provisioning
- Ansible para configuración
- InSpec para testing

Docker ya está configurado en la Vagrant del curso (podéis validarlo con el comando ```docker 
ps -a```), además para facilitar el trabajo se han descargado las imágenes que se usarán
durante el curso.

Para instalar Test Kitchen y InSpec tenemos dos opciones:
- Instalar la última versión del Chef Development Kit
- Instalar Ruby, las gemas de InSpec y las gemas de Test Kitchen

Optaremos por la primera opción, ya que es mucho más fácil:

```yum install https://packages.chef.io/files/stable/chefdk/2.3.4/el/7/chefdk-2.3.4-1.el7.x86_64.rpm```

Ahora ya tenemos instalado Test Kitchen e Inspec, pero debemos instalar los módulos que nos permitirán 
hacer el testing con Ansible y Docker. Se instalan como gemas de Ruby. ChefDK nos proporciona un entorno
estable de Ruby en el que podemos añadir las gemas de la siguiente forma:

```
chef gem install kitchen-docker
chef gem install kitchen-ansible
```

Validamos que tenemos inspec disponible:

```text
[root@localhost ~]# inspec --version
1.36.1

Your version of InSpec is out of date! The latest version is 1.42.3.
```

Y que test kitchen también está funcionando:

```text
[root@localhost ~]# kitchen --version
Test Kitchen version 1.17.0
```

Ahora ya tenemos preparado nuestro entorno para testing.


## Más información

- La última versión del ChefDK se puede consultar en https://downloads.chef.io/chefdk
- Kitchen-Ansible es un producto Open Source y podéis saber más de él en https://github.com/neillturner/kitchen-ansible
- Kitchen-Docker es un producto Open Source y podéis saber más de él en https://github.com/test-kitchen/kitchen-docker
- Podéis ver el ecosistema de plugins/drivers de test-kitchen en 
https://github.com/test-kitchen/test-kitchen/blob/master/ECOSYSTEM.md