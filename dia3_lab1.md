# Dia 3 - Laboratorio 1

El objetivo de este laboratorio es familiarizarse con Jinja y sus estructuras de control

Estudiaremos un rol con un templating algo complejo, y jugaremos con como simplificar el templating.

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

## Ejercicio 1 - Lectura del rol "laboratorio-jinja2"

Análicemos en grupo el rol "laboratorio-jinja2" y las estructuras de control que hay en la plantilla Jinja.

Especial atención en:
- Includes
- Composición de cadenas para generar nombres de variables

## Ejercicio 2 - crear un playbook que aplique el rol

Crearemos un rol que aplique el rol laboratorio-jinja2 y el rol nginx que tenemos de otros dias
a la máquina de laboratorio.

## Ejercicio 3 - crear un filtro custom de Jinja

Como habremos observado, el siguiente bloque de código puede ser complejo:

```jinja2
{% if ansible_os_family == 'RedHat' %}<img src="https://upload.wikimedia.org/wikipedia/en/thumb/6/6c/RedHat.svg/93px-RedHat.svg.png" />{% else %}{{ ansible_os_family }}{% endif %}
```

Como se repite en dos líneas, podemos crear un filtro custom de Jinja que nos devuelva el logo adecuado.

Para ello crearemos el fichero custom_plugins.py en la carpeta "filter_plugins" del rol

```bash
mkdir roles/laboratorio-jinja2/filter_plugins
```

Ejemplo de fichero custom_plugins.py

```python
class FilterModule(object):
    ''' Custom filters are loaded by FilterModule objects '''

    def filters(self):
        ''' FilterModule objects return a dict mapping filter names to
            filter functions. '''
        return {
            'get_logo': self.get_logo,
        }

    def get_logo(self, value):
        return_string = value
        if return_string == 'RedHat':
            return_string = '<img src="{0}" />'.format('https://upload.wikimedia.org/wikipedia/en/thumb/6/6c/RedHat.svg/93px-RedHat.svg.png')
        elif return_string == 'CentOS':
            return_string = '<img src="{0}" />'.format('https://upload.wikimedia.org/wikipedia/commons/thumb/b/bf/Centos-logo-light.svg/93px-Centos-logo-light.svg.png')
        return return_string
```

Y modificamos las lineas complejas por:
```jinja2
    <tbody>
    <tr>
        <td>{{ ansible_os_family | get_logo }}</td>
        <td>{{ ansible_distribution | get_logo }}</td>
        <td>{{ ansible_distribution_version }}</td>
    </tr>
    </tbody>
```

Tras esto reaplicamos el playbook y debería funcionar igual, pero con una plantilla mucho más legible

## Ejercicio 4 -- más info en el report

Ahora implementaremos una nueva parte del report que muestre la información de los diferentes bloques de memoria y su uso.



# Fin del laboratorio

En este laboratorio se habrán adquirido los siguientes conocimientos:
- Templating de jinja y estructuras de control
- Filtros custom de Jinja

Procederemos a la destrucción del laboratorio:

```bash
ansible-playbook borrar-labs5s2.yml
```