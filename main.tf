terraform {
  //declara que este projeto 
  //precisa do "provider" 
  //do Docker (um plugin que 
  //ensina o Terraform a falar 
  //com o Docker).
  required_providers {
    docker = {
      //diz onde baixar esse plugin
      source = "kreuzwerker/docker"
      //trava numa versão compatível com 3.x
      version = "~> 3.0"
    }
  }
}
//configura a conexão com o Docker local — como 
//está vazio {}, ele usa a configuração padrão
provider "docker" {}

//declara que deve existir localmente a imagem 
//nginx:latest. Se não existir, o Terraform baixa.
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "web" {
  name  = "meu-container-web"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    host_path      = "${path.cwd}/site"
    container_path = "/usr/share/nginx/html"
    read_only      = true
  }
}
resource "docker_volume" "db_data" {
  name = "meu-projeto-db-data"
}

resource "docker_image" "postgres" {
  name = "postgres:16"
}

resource "docker_container" "db" {
  name  = "meu-container-db"
  image = docker_image.postgres.image_id
  env   = ["POSTGRES_PASSWORD=senha123"]
  ports {
    internal = 5432
    external = 5432
  }
  volumes {
    volume_name    = docker_volume.db_data.name
    container_path = "/var/lib/postgresql/data"
  }
}