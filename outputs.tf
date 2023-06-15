output "permission_sets" {
  value = aws_ssoadmin_permission_set.this
}

output "assignments" {
  value = aws_ssoadmin_account_assignment.this
}