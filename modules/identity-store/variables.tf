variable "users" {
  type = map(object({
    first_name = string
    last_name  = string
    email      = string
  }))
}

variable "groups" {
  type = map(object({
    display_name = string
    description  = string
  }))
}