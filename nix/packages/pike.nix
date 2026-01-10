{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pike";
  version = "0.3.88";

  src = fetchFromGitHub {
    owner = "jameswoolfenden";
    repo = "pike";
    rev = "v${version}";
    hash = "sha256-lyHYRZbRJKtp+MpkcxIrRF1nq3H8Tw8km4Hv6Ib62Zk=";
  };

  vendorHash = "sha256-1V8LODOmRO4Y9z+UCi+DGT96LY1F8bOUMMCNzbk9AgI=";

  # Tests require Terraform installation
  doCheck = false;

  meta = {
    description = "Generate IAM policies from Terraform/CloudFormation";
    homepage = "https://github.com/jameswoolfenden/pike";
  };
}
