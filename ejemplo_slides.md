---
title: "¿Cómo afrontar la práctica de Distribuidos?"
subtitle: "Sin pegarse un tiro ni pegarselo a nadie. Documento en redacción, revisa última versión en https://ggelado.github.io/diaposDistribuidos/diapos.pdf"
author: "Gonzalo"
date: "Marzo 2026"
babel-lang: spanish
documentclass: beamer
classoption:
  - xcolor=dvipsnames
  - usepdftitle=false
header-includes:
  - \usepackage{presentation}

---

# Introducción

## ¿De qué va esto?

Va de que los 4 nodos de triqui (p.ej.) hablen entre ellos, se manden ficheritos, mensajitos y demás, pero que ninguno sea un servidor, **TODOS SON SERVIDORES Y CLIENTES**.

Eso es el P2P (lo que se hacía hace años con los torrents ilegales).

Ya lo iremos definiendo sobre la marcha.

## ¿Qué necesito?

- Entorno linux:
  
  - WSL
  
  - Máquina Virtual
  
  - Linux nativo
  
  - ¿Triqui? ¿Escritorios virtuales? (si tu paciencia y cordura lo permiten)

- Conexión con triqui

- Usar el Gestor de Entregas de Triqui (ya explicaré cómo funciona)

## ¿Empezamos?

1. Coge un editor cómodo (vas a dedicarle un ratito)
   
   - VSCode
   
   - CLion
   
   - ¿Nano? ¿vi? ¿emacs?

2- Pon tu entorno de trabajo

3- Enciende la VPN

# Arrancando

## Ficheros de Trabajo

Ejecuta en una terminal

```bash
wget https://laurel.datsi.fi.upm.es/_media/docencia/asignaturas/sd
/ring-2026.tgz
# 2 líneas para que no se corte
tar xvfz ring-2026.tgz
cd DATSI/SSDD/ring.2026/src/
```

Así, directo, sin pensar.

## Comunicación con Triqui

Vas a pasar muchas veces ficheros de triqui a tu ordenador y viceversa, puedes hacer SCP todo el rato, pero vas a deprimirte.

- [Bitvise](https://bitvise.com/ssh-client-download) (Mi preferido para Windows)

- [Uso Ubuntu nativo](https://itsupport.cs.uvic.ca/tutorials/linux_sftp/#:~:text=SFTP%20using%20Linux%20GUI%20File%20Browser%20(Nautilus))

O si no...

```bash
scp ficheroOrigen usuario@triqui.fi.upm.es:
~/DATSI/SSDD/ring.2026/src/

# 2 líneas para que no se corte
```

Usa esos programas, por favor, te salvan la vida.

## Gestor de Entregas

Funciona igual que en SSOO:

**ADVERTENCIA**: Por alguna razón el Gestor espera que los ficheros estén en `~/DATSI/SSDD/ring.2026/` pero los profes han puesto el código de la plantilla en `todoEso/src`, por lo que **falla**. Saca los ficheros de src y llévalos a esa carpeta.

Con Bitvise y demás es sencilla la operación.

## Gestor de Entregas (2)

Cada vez que queramos hacer una entrega:

1. Entrar en triqui

2. Poner **DONDE SEA** (en una terminal): `entrega.sd ring.2026`

3. Introducir el número de matrícula cuando se solicite

4. Confirmar

5. Cuando tenga ganas el corrector (cada 3 hrs, a las en punto) te mandará un correo listo para deprimirte hablando sobre la excelencia de tu código

# A picar código

## ¿Dónde se toca?

- ring_cln.c

- ring_srv.c

- common.c

- include/common.h

Y ya está, el resto de ficheros se miran pero no se tocan.

## ¿Cómo empiezo?

Pues por el principio.

No empieces a leerte todo el enunciado, vamos por partes:

# Fase 1 - Paso 1

## Desplegar parte servidora

Vamos con el fichero `ring_cln.c`. 

**Objetivo**: 

- Debe guardar la información recibida en sus parámetros e implementarse la función ring_self a partir de ella.
- Debe crear el socket de servicio, para lo que puede usar la función create_socket_srv, tal como se hace en el ejemplo propuesto. Esa función devuelve el puerto seleccionado por el sistema operativo en formato de red, que, a su vez, debe ser devuelto por esta función.
- Debe crear el *thread* de servicio que ejecutará la función server_thread de ring_srv.c pasándole como argumento el socket de servicio. Para ello, puede usar la función create_thread de common.c, que crea un *thread* de tipo *detached*.

## ¿Qué tenemos?

Nos dan esto

```c
// inicia el nodo añadiéndolo a la red P2P si ya está creada;
// los puertos e IPs deben estar en formato de red;
// debe devolver en el último parámetro el puerto reservado en formato red;
// retorna 0 si OK y -1 si error
int ring_init(const char *shrd_dir, unsigned int local_ip, unsigned int remote_ip, unsigned short remote_port, unsigned short *alloc_port) {
    if (initialize()) return -1; // ya está inicializada
    return 0;
}
```

## ¿Qué nos dan y cuál es la salida?

En C (lenguaje fantástico) algunos parámetros son de entrada y otros son de salida:

- `const char *shrd_dir`: Entrada

- `unsigned int local_ip`: Entrada

- `unsigned int remote_ip`: Entrada

- `unsigned short remote_port`: Entrada

- `unsigned short *alloc_port`: **SALIDA**

En esta 1era fase vamos a ignorar los remotos, pues de momento es solamente local.

Vamos a leer el enunciado poco a poco:

Debe guardar la información recibida en sus parámetros e implementarse la función ring_self a partir de ella.

## Guardar información recibida en sus parámetros

Pues vamos a hacer eso, eso es sencillo.

Variable arriba y listo:

```c
shared_dir_copia = strdup(shrd_dir);
ip_copia = local_ip;
```

`strdup` para copiar los *Strings*.

## Implementar `ring_self`

```c
int ring_self(unsigned int *ip, unsigned short *port)
```

Son parámetros de salida (punteros), ya sabes cómo va

```c
if (!is_initialized()) return -1; // no está inicializada
*ip = ip_copia;
// *port = port_copia; // ni caso, ya lo veremos
return 0;
```

## Debe crear el socket de servicio, para lo que puede usar la función **create_socket_srv**, tal como se hace en el ejemplo propuesto.

¿Qué ejemplo?

Pues este

```c
int main(int argc, char *argv[]) {
    int s, s_conec;
    unsigned int addr_size;
    unsigned short port;
    struct sockaddr_in clnt_addr;

    // inicializa el socket y lo prepara para aceptar conexiones
    if ((s=create_socket_srv(&port)) < 0) return 1;
    printf("Reservado el puerto %d\n", ntohs(port));
```

Ejemplo: `server.c`

## Vamos con ello, a copiar sin piedad

```c
if ((s=create_socket_srv(&port_copia)) < 0) return 1;
```

(por cierto, ya tenemos el valor de retorno de `*alloc_port`)

Ya podemos completar en ring_self

(por cierto, recuerda que tienes que guardar ese puerto en alguna variable)

## Debe crear el *thread* de servicio que ejecutará la función server_thread de ring_srv.c pasándole como argumento el socket de servicio. Para ello, puede usar la función create_thread de common.c, que crea un *thread* de tipo *detached*.

¿Cómo? ¿Qué pone ahí?

Poco a poco, no nos asustemos:

Vamos a buscar el ejemplo ese que dice, a ver si vemos algo.

Por cierto, ahí te lo dice pero... es en `ring_srv.c`.

## A ver el ejemplito

```c
while(1) {
    addr_size=sizeof(clnt_addr);
    // acepta la conexión
    if ((s_conec=accept(s, (struct sockaddr *)&clnt_addr, &addr_size))<0){
        perror("error en accept"); close(s); return 0;
    }
    printf("conectado cliente con ip %s y puerto %u\n",
            inet_ntoa(clnt_addr.sin_addr), ntohs(clnt_addr.sin_port));
    // crea el thread de servicio pasándole el argumento por valor
    create_thread(request_handler, (void *)(long)s_conec);
}
close(s); // cierra el socket general
```

Pues ya sabes, A COPIAR SIN PIEDAD

## Nos vamos al código

```c
// función para el thread que implementa la funcionalidad de servidor
// debe recibir como argumento el socket de servicio
void *server_thread(void *arg){
    return NULL;
}
```

y a hacer lo mismo.

Acuerdate de dar de alta variables y demás para que compile, y que en vez de retornar 0 retornamos NULL (es `void`), PERO EL RESTO IGUAL.

# ¿Y ya está?

## ¿Parte 1 - Paso 1 terminada?

Solo hay una forma de saberlo, probarlo:

Según el enunciado, hay que hacer esto:

```
ssoo@triqui1:src$ mkdir dir1
ssoo@triqui1:src$ ./ring dir1
Bienvenido a la red P2P RING
----------------------------
El equipo triqui1.fi.upm.es con IP 138.100.240.42 y puerto 38503 (PID 2542419) es el primer nodo de una nueva red

Seleccione operación (línea vacía para terminar; en menús internos para volver a menú principal)
    I: obtiene Info de nodo local| P: getPid|S: Sucesor|R:sucesor Remoto|U: sUcesor de sucesor remoto|D: Download|L: Lookup fichero|G: Get fichero 
```

## 

El resultado de esa operación (IP 138.100.240.42 port 38503), que corresponde a la operación ring_self, es correcto ya que coincide con los datos mostrados en el mensaje de bienvenida.
Podemos verificar en otra ventana que ese proceso (PID=2542419) está escuchando por ese puerto:

```
ssoo@triqui1:src$ ss -tap | grep 38503
LISTEN    0      5                      0
```

# Parece que funciona

## Entonces...

Ya te funciona algo, ahora a entregar por triqui y rezar

El paso 2 para la siguiente versión de este documento.

## Y mañana...

![](assets/2026-03-04-19-37-23-image.png)
