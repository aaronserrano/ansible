# Dia 3 - Laboratorio 2

El objetivo de este laboratorio es familiarizarse con la creación de módulos custom para simplificar
el código y mejorar la idempotencia de nuestros playbooks.

Analizaremos un rol de ejemplo y adaptaremos una de sus características para que use un módulo
custom que crearemos.

## Arrancar el laboratiorio

```bash
ansible-playbook crear-lab5s2.yml
```

Tras unos segundos este playbook habrá creado 1 máquina Centos 7, podéis ver su IP's en el 
fichero ```inventories/dia2lab5.yml```

Para acceder a ellas podréis hacerlo mediante el usuario "centos", con la clave pública que
se os ha dado justo con el fichero aws_vault.yml

Recomendamos dejar la clave pública en el directorio $HOME del usuario que vayáis a usar 
en la VM de laboratorio que se usa para control. De esta forma los comandos de la documentación
se ajustarán al entorno.

Ejemplo de comando para acceder a una de las máquinas de lab:

```ssh -i $HOME/curso-itnow.pem centos@a.b.c.d```

## Ejercicio 1 - Lectura del rol "laboratorio-custommodule"

Análicemos en grupo el rol "laboratorio-custommodule" 

Especial atención en como usamos el módulo command para "saltarnos" la falta de un módulo que haga 
lo que queremos




## Ejercicio 2 - crear un playbook que aplique el rol

Crearemos un rol que aplique el rol laboratorio-custommodule en la máquina de laboratorio

Le llamaremos d3l2_custommodule.yml

Veremos al aplicar que el paso de probar la conectividad SIEMPRE es marcado como changed.



## Ejercicio 3 - crear un módulo custom en python

Ansible tiene la clase AnsibleModule que nos permite crear módulos custom para Ansible de forma
más comoda que si lo hicieramos a mano.

Facilita:
- parsear la entrada
- devolver la salida en formato json
- invocar programas externos

Esto es importante, teniendo en cuenta que ansible espera que sus módulos custom le devuelvan lo siguiente en json:

```json
{'changed': false, 'failed': true, 'msg': 'could not reach the host'}
```

El siguiente ejemplo de módulo en python cubriría lo que hace nuestro script:

```python
#!/usr/bin/python
from ansible.module_utils.basic import AnsibleModule

def can_reach(module, host, port, timeout):
    nc_path = module.get_bin_path('nc', required=True)
    args = [nc_path, "-w", str(timeout),
            host, str(port)]
    (rc, stdout, stderr) = module.run_command(args)
    return rc == 0

def main():
    module = AnsibleModule(
        argument_spec=dict(
            host=dict(required=True),
            port=dict(required=True, type='int'),
            timeout=dict(required=False, type='int', default=3)
        ),
        supports_check_mode=True
    )

    # In check mode, we take no action
    # Since this module never changes system state, we just
    # return changed=False
    if module.check_mode:
        module.exit_json(changed=False)

    host = module.params['host']
    port = module.params['port']
    timeout = module.params['timeout']

    if can_reach(module, host, port, timeout):
        module.exit_json(changed=False)
    else:
        msg = "Could not reach %s:%s" % (host, port)
        module.fail_json(msg=msg)

if __name__ == "__main__":
    main()
```

Implementaremos este script en el directorio "library" del playbook con el nombre "can_reach"

Y modificaremos la llamada para que use el módulo en la tasklist del rol:

```yaml
- name: run my custom module
  can_reach: host=www.google.com port=80 timeout=1
```


## Ejercicio 4: ver ejemplos de módulos

https://github.com/ansible/ansible/tree/devel/lib/ansible/modules

Y recomendado, capítulo 12 del libro "Ansible: Up and Running"

# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Ejecución de funciones no disponibles en ansible mediante scripts
- Creación de módulos custom para cubrir necesidades que ansible no cubre

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs5s2.yml
```