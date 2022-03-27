FROM ubuntu:18.04
# Actualizo la base de datos de Ubuntu
RUN apt-get update && apt-get -y -q upgrade 
# Configuro la zona horario
ENV TZ=America/Argentina/Buenos_Aires
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# Instalo postgres
RUN apt-get -y -q install postgresql-10 postgresql-client-10 postgresql-contrib-10
#----------------------------------------------------------------------------
# Permitimos que se puede acceder a PostgreSQL
# desde clientes remotos
#RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/10/main/pg_hba.conf
#----------------------------------------------------------------------------
#
# Copio el archivo personalizado de configuración de postgres 
COPY ./file/pg_hba.conf /etc/postgresql/10/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/10/main/pg_hba.conf
#-----------------------------------------------------------------------------
# Permitimos que se pueda acceder por cualquier
# IP que tenga el contenedor
# RUN echo "listen_addresses='*'" >> /etc/postgresql/10/main/postgresql.conf
#-----------------------------------------------------------------------------
#
# Copio el archivo personalizado de configuración de postgres 
COPY ./file/postgresql.conf /etc/postgresql/10/main/postgresql.conf
RUN  chown postgres:postgres /etc/postgresql/10/main/postgresql.conf
##Exponemos el Puerto de la Base de Datos
EXPOSE 5432
# Cambio a postgres
USER postgres
# Levanto la base de datos
RUN /etc/init.d/postgresql start \
&& psql --command "CREATE USER pguser WITH SUPERUSER PASSWORD 'secret';" \
&& createdb -O pguser Custom_db \
&& /etc/init.d/postgresql stop
# Cambio al usuario root
USER root
# Creamos los volúmenes necesarios para guardar
# el backup de la configuración, logs y bases de datos
# y poder acceder desde fuera del contenedor
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
# Cambio a l usuario postgres
USER postgres
# Levanto la base de datos como corresponde.
CMD ["/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
