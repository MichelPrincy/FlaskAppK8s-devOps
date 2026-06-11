FROM python:3.7-slim

# Crée un utilisateur non-privilégié pour des raisons de sécurité
RUN useradd -m flask

WORKDIR /home/flask

# Copie d'abord uniquement le fichier des dépendances pour optimiser le cache Docker
COPY requirements.txt ./

# Installe les dépendances sans utiliser de venv (inutile dans un conteneur)
RUN pip install --no-cache-dir -r requirements.txt

# Copie le reste du code de l'application
COPY . .

# Donne les droits d'exécution et change le propriétaire du dossier
RUN chmod +x app.py test.py && \
    chown -R flask:flask /home/flask

# Configure la variable d'environnement requise par Flask
ENV FLASK_APP=app.py

# Expose le port interne de l'application
EXPOSE 5000

# Bascule sur l'utilisateur sécurisé
USER flask

# Commande par défaut pour lancer l'application
CMD ["python", "app.py"]