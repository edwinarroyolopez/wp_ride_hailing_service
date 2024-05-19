FROM postgres:latest

ENV POSTGRES_USER=wp_user
ENV POSTGRES_PASSWORD=wp_user
ENV POSTGRES_DB=postgres

EXPOSE 5432

CMD ["postgres"]