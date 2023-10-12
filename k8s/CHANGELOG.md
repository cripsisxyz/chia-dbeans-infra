# 0.6.0
* Añadir el componente cortex-tenant que permite segmentación de tenants mediante labels de prometheus
 
# 0.5.2
* Se modifica la config de mimir, se ha modificado una ruta en la había un caracter en el namespace de synthetix-saas-dev y se ha hecho el sealed

# 0.5.1
* Se modifica el sealed secret con la configuración de la config de mimir

# 0.5.0
* Se añade Loki componente

# 0.4.0
* Se añaden todos los workers de celery (synthetix-scheduler)
  - celery-worker-alerting-deployment.yml
  - celery-worker-manager-deployment.yml
  - celery-worker-optimizer-deployment.yml
  - celery-worker-programmer-deployment.yml
  - celery-worker-results-deployment.yml
  - celery-agent-worker-results-webrobot-deployment.yml
  - celery-agent-worker-results-webscenario-deployment.yml

# 0.3.0
* Se añade el componente celery-flower de synthetix-scheduler
* Reciclado de variables de entorno que se vayan a compartir entre los distintos deployments de synthetix-scheduler

# 0.2.0
* Se añade el componente de grafana

# 0.1.0
* Se añade el componente celery-beat de synthetix-scheduler

# 0.0.3
* Se añaden los componentes de mimir sin labels y selector dummy, se mete como sealed la configuración de mimir

# 0.0.2
* Se añade el dockerconfig para que kubernetes sepa como descargar las imágenes de nuestro Nexus de Datadope en el namespace synthetix-saas-dev

# 0.0.1
* Primera versión con la estructura base y los primeros workloads.
