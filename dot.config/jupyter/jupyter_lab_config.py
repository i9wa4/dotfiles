# Configuration file for lab.

c = get_config()  #noqa

# c.FileCheckpoints.checkpoint_dir = "${HOME}/.cache/.ipynb_checkpoints"
c.ExtensionApp.open_browser = False
c.LabServerApp.open_browser = False
c.ServerApp.open_browser = False
c.ServerApp.use_redirect_file = False
