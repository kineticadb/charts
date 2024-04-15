!!! warning "On-Prem Kinetica SQLAssistant - Nodes Groups, GPU Counts & VRAM Memory"    
    To run the Kinetica SQLAssistant locally requires additional GPUs to be available in a separate
    Node Group labeled `app.kinetica.com/pool=compute-llm`. 
    In order for the On-Prem Kinetica LLM to run it requires **40GB GPU VRAM** therefore the number of GPUs
    automatically allocated to the SQLAssistant pod will ensure that the 40GB VRAM is available
    e.g. 1x A100 GPU or 2x A10G GPU. 

    ```shell title="Label Kubernetes Nodes for LLM"
    kubectl label node k8snode3 app.kinetica.com/pool=compute-llm
    ```
