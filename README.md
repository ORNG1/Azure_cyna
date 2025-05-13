# Azure_cyna
Repository for DevOps in Cyna's Azure cloud.

Ce repo contient les fichiers nécessaires pour faire la démonstration suivante : Déploiement automatisé d'Azure Kubernetes Services (AKS).

Utilisation de Docker pour créer les images contenant Nginx et une page web en html

Déploiement des conteneurs auto gérés par AKS en utilisant les images Docker créées avant.

Load Balencing fait par le AKS automatiquement (Free tier)

Mise en place de la pipelince GitHub actions : modification de la page web déployée sur les pods ---> curl automatisé pour récuperer la pag ---> si condition existante ---> déploiement

Mettre le tout en schéma

Modifier le hardcoding des identifiants dans les fichiers de configurations et utiliser des variables (export des datas puis pousser via variables)