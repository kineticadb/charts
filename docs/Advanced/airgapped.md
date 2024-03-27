# Air-Gapped Environments

## Obtaining the Kinetica Images

--8<-- "docs/Advanced/kinetica_images_list_for_airgapped_environments.md"

Please select the method to transfer the images: -

=== "mindthegap"

    It is possible to use 
    [`mesosphere/mindthegap`](https://github.com/mesosphere/mindthegap)

    !!! quote "mindthegap"
    `mindthegap` provides utilities to manage air-gapped image bundles, 
    both creating image bundles and seeding images from a bundle into 
    an existing OCI registry or directly loading them to `containerd`.

    This makes it possible with `mindthegap` to

    * create a single archive bundle of all the required images outside the 
    air-gapped environment
    *  run `mindthegap` using the archive bundle on the Kubernetes Nodes to
    bulk load the images into `contained` in a single command.

    Kinetica provides two `mindthegap` yaml files which list all the necessary images
    for Kinetica for Kubernetes.

    * [CPU only]()
    * [ CPU & nVidia CUDA GPU]()

    ### Install `mindthegap`

    ``` shell title="Install mindthegap"
    wget https://github.com/mesosphere/mindthegap/releases/download/v1.13.1/mindthegap_v1.13.1_linux_amd64.tar.gz
    tar zxvf mindthegap_v1.13.1_linux_amd64.tar.gz
    ```

    ### mindthegap - Create the Bundle

    ``` shell title="mindthegap create image-bundle"
    mindthegap create image-bundle --images-file mtg.yaml --platform linux/amd64
    ```

    where `--images-file` is either the CPU or GPU Kinetica `mindthegap` yaml file.

    ### mindthegap - Import the Bundle
    
    #### mindthegap - Import to `containerd`

    ``` shell title="mindthegap import image-bundle"
    mindthegap import image-bundle --image-bundle images.tar [--containerd-namespace k8s.io]
    ```

    If `--containerd-namespace` is not specified, images will be imported into `k8s.io` namespace. 

    !!! note "`sudo` required"
        Depending on how `containerd` has been installed and configured it may
        require running the above command with `sudo`

    #### mindthegap - Import to an internal OCI Registry

    ``` shell title="mindthegap import image-bundle"
    mindthegap push bundle --bundle <path/to/bundle.tar> \
    --to-registry <registry.address> \
    [--to-registry-insecure-skip-tls-verify]
    ```

=== "containerd"

    It is possible with `containerd` to pull images, save them and load them either into 
    a Container Registry in the air gapped environment or directly 
    into another `containerd` instance. 
    
    If the target `containerd` is on a node running a Kubernetes Cluster then these
    images will be sourced by Kubernetes from the loaded images, via CRI, with no requirement 
    to pull them from an external source.

    !!! note "`sudo` required"
        Depending on how `containerd` has been installed and configured many of the example calls below may
        require running with `sudo`

    ### containerd - Using `containerd` to pull and export an image

    Similar to `docker pull` we can use `ctr image pull` so to pull the core Kinetica DB cpu based image

    ``` shell title="Pull a remote image (containerd)"
    ctr image pull docker.io/kineticastagingcloud/kinetica-k8s-cpu:v7.2.0-3.rc-3
    ```

    We now need to export the pulled image as an archive to the local filesystem.

    ``` shell title="Export a local image (containerd)"
    ctr image export kinetica-k8s-cpu-v7.2.0-3.rc-3.tar \
    docker.io/kineticastagingcloud/kinetica-k8s-cpu:v7.2.0-3.rc-3
    ```

    We can now transfer this archive (`kinetica-k8s-cpu-v7.2.0-3.rc-3.tar`) to the Kubernetes Node inside 
    the air-gapped environment.

    ### containerd - Using `containerd` to import an image 

    Using `containerd` to import an image on to a Kubernetes Node on which a Kinetica Cluster is running.

    ``` shell title="Import the Images"
    ctr -n=k8s.io images import kinetica-k8s-cpu-v7.2.0-3.rc-3.tar
    ```

    !!! warning "`-n=k8s.io`"
        Whilst it is possible to use `ctr images import kinetica-k8s-cpu-v7.2.0-3.rc-3.tar` 
        to import the image in order for the image to be visible to Kubernets it is necessary 
        to specify `-n=k8s.io`.

    ### containerd - Verifying the image is available

    To verify the image is loaded into `containerd` on the node run the following on the node: -

    ``` shell title="Verify containerd Images"
    ctr image ls
    ```

    To verify the image is visible to Kubernetes on the node run the following: -

    ``` shell title="Verify CRI Images"
    crictl images
    ```

=== "docker"

    It is possible with `docker` to pull images, save them and load them into
    an OCI Container Registry in the air gapped environment.

    ``` shell title="Pull a remote image (docker)"
    docker pull --platformlinux/amd64 docker.io/kineticastagingcloud/kinetica-k8s-cpu:v7.2.0-3.rc-3
    ```

    ``` shell title="Export a local image (docker)"
    docker export --platformlinux/amd64 -o kinetica-k8s-cpu-v7.2.0-3.rc-3.tar \
    docker.io/kineticastagingcloud/kinetica-k8s-cpu:v7.2.0-3.rc-3
    ```
    
    We can now transfer this archive (`kinetica-k8s-cpu-v7.2.0-3.rc-3.tar`) to the Kubernetes Node inside 
    the air-gapped environment.

    ### docker - Using `docker` to import an image 

    Using `docker` to import an image on to a Kubernetes Node on which a Kinetica Cluster is running.

    ``` shell title="Import the Images"
    docker import --platformlinux/amd64 kinetica-k8s-cpu-v7.2.0-3.rc-3.tar registry:repository/kinetica-k8s-cpu:v7.2.0-3.rc-3
    ```