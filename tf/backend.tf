terraform {
  cloud {
    organization = "alex-tfplayground"

    workspaces {
      name = "technical-assessment-hsx"
    }
  }
}