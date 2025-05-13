FROM nginx:alpine

# Supprime la page par défaut
RUN rm /usr/share/nginx/html/index.html

# Copie ta page personnalisée
COPY index.html /usr/share/nginx/html/

# Expose le port 80
EXPOSE 80
