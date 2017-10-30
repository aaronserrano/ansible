# Dia 4 - Lab 2 - InSpec

## Que es InSpec

InSpec es un framework de testing open-source para infraestructura, que usa un lenguaje pseudo-humano para especificar 
requerimientos de compliance, seguridad y otro tipo de políticas. Se puede integrar de forma fácil de forma que ejecute
esos tests de forma automática en cualquier fase del ciclo de vida de un desarrollo.

## Sintáxis de InSpec

La sintaxis de InSpec permite escribir tests de forma que quien los escriba no tiene porqué saber como implementar
el código que los hace válidos.

Es decir, el test puede ser escrito por alguien (Arquitecto) que conoce los requerimientos, pero que no 
conoce la herramienta con la que se van a implementar estos requerimientos.

Un ejemplo de test independiente de InSpec sería:

```ruby
control "cis-1-2-1" do                      
  impact 1.0                                
  title "1.2.1 Verify CentOS GPG Key is Installed (Scored)"
  desc "CentOS cryptographically signs updates with a GPG key to verify that they are valid."
  describe command('rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey') do
   its('stdout') { should match /CentOS 7 Official Signing Key/ }
  end
end
```

La apertura "control" nos indica que estamos implementando un bloque de validación. Estos bloques
se llaman "contols" en la DSL de InSpec.

Impact define el peso de ese control, es un entero y sus valores indican:
- 0.0<0.4 : control con criticidad baja
- 0.4<0.7 : control con criticidad media
- 0.7<=1.0: control con criticidad alta

Title y Desc son metadatos del control. 

Cada control al menos debe tener un bloque "describe" que indica un test.

Cada bloque describe indica:
- Un recurso de inspec (puede ejecutar un comando, ver paquetes, estados de puertos...)
- Que condición cumple la ejecución de ese recurso de inspec y sus parámetros

Más info de la DSL de InSpec: https://www.inspec.io/docs/reference/dsl_inspec/

**Actividad** : ver los ejemplos que hay en el enlace anterior

## Probando InSpec en nuestra vagrant

InSpec puede servir para validar un entorno local, o uno remoto. Sirve tanto para Unix como para Windows.
Vamos a implementar el test de ejemplo que tenemos más arriba (lo guardaremos como ```inspec_local.rb```)


```text
[root@localhost ~]# inspec exec inspec_local.rb 

Profile: tests from inspec_local.rb
Version: (not specified)
Target:  local://

  ✔  cis-1-2-1: 1.2.1 Verify CentOS GPG Key is Installed (Scored)
     ✔  Command rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey stdout should match /CentOS 7 Official Signing Key/

Profile Summary: 1 successful control, 0 control failures, 0 controls skipped
Test Summary: 1 successful, 0 failures, 0 skipped

```

Vemos que la ejecución devuelve un informe de cuantos tests han pasado correctamente, cuantos no, y un informe con la 
salida de los mismos.

## Probando InSpec en un sistema remoto

Vamos a lanzar el laboratorio de una sola máquina:

```text
ansible-playbook crear-lab-1vm.yml
```

Tomamos la IP de la VM que se ha creado del inventario:

```text
[root@localhost ansible-devops]# cat inventories/
empty.txt   lab1vm.yml  
[root@localhost ansible-devops]# cat inventories/lab1vm.yml 

34.241.63.101
```

Y ejecutamos inspec contra esa máquina:

```text
[root@localhost ansible-devops]# inspec exec inspec_local.rb -t ssh://centos@34.241.63.101 -i $HOME/curso-itnow.pem 

Profile: tests from inspec_local.rb
Version: (not specified)
Target:  ssh://centos@34.241.63.101:22

  ✔  cis-1-2-1: 1.2.1 Verify CentOS GPG Key is Installed (Scored)
     ✔  Command rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey stdout should match /CentOS 7 Official Signing Key/

Profile Summary: 1 successful control, 0 control failures, 0 controls skipped
Test Summary: 1 successful, 0 failures, 0 skipped
```

Vemos que el resultado es el mismo y que la ejecución se realiza de forma más o menos rápida. Al igual que Ansible,
InSpec no requiere que InSpec esté instalado en los nodos remotos que se están validando.

## Testing con otros módulos de inspec

Vamos a crear un test para validar que VIM (un editor típico de unix) está instalado en nuestra máquina, para ello, 
crearemos un fichero ```test_vim.rb``` y empezaremos a escribir:

1. Definir el bloque de control

```ruby
control "vim-installed" do

end
```

2. Definir los metadatos

```ruby
control "vim-installed" do
  impact 1.0                                
  title "Verificar que VI - Improved está instalado"
  desc "Ningún sistema puede sobrevivir sin el mejor editor del mundo"
   
end
```

3. Definir el bloque de recurso

Existe el recurso 'package' que permite evaluar condiciones sobre los paquetes (ver 
https://www.inspec.io/docs/reference/resources/package/) , lo usaremos para validar que el paquete de vim está 
instalado.

```ruby
control "vim-installed" do
  impact 1.0                                
  title "Verificar que VI - Improved está instalado"
  desc "Ningún sistema puede sobrevivir sin el mejor editor del mundo"
  describe package('vim-enhanced') do
   it { should be_installed }
  end
end
```

(ver la documentación del recurso antes de seguir)

4. Ejecutar el test contra nuestra máquina

```
[root@localhost ansible-devops]# inspec exec test_vim.rb -t ssh://centos@34.241.63.101 -i $HOME/curso-itnow.pem 

Profile: tests from test_vim.rb
Version: (not specified)
Target:  ssh://centos@34.241.63.101:22

  ×  vim-installed: Verificar que VI - Improved está instalado (expected that `System Package vim-enhanced` is installed)
     ×  System Package vim-enhanced should be installed
     expected that `System Package vim-enhanced` is installed

Profile Summary: 0 successful controls, 1 control failure, 0 controls skipped
Test Summary: 0 successful, 1 failure, 0 skipped
```

Vemos que se ha generado un fallo, porque vim no está intsalado.

5. Instalar vim y volver a ejecutar

Instalaremos vim:
```text
ssh -i $HOME/curso-itnow.pem centos@34.241.63.101 "sudo yum -y install vim"
```

Y volveremos a ejecutar. Que ha cambiado?


