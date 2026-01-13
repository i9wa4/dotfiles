{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pike";
  version = "0.3.89";

  src = fetchFromGitHub {
    owner = "jameswoolfenden";
    repo = "pike";
    rev = "v${version}";
    hash = "sha256-9As8U0wVcZSgqhMe2/+Cneh0mra24k6dYnSqnIYCesg=";
  };

  vendorHash = "sha256-1V8LODOmRO4Y9z+UCi+DGT96LY1F8bOUMMCNzbk9AgI=";

  # Tests require Terraform installation
  doCheck = false;

  meta = {
    description = "Generate IAM policies from Terraform/CloudFormation";
    homepage = "https://github.com/jameswoolfenden/pike";
  };
}
