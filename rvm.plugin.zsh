# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name rvm
# @description Zsh plugin to set RVM environment variables.
# @repository https://github.com/johnstonskj/zsh-rvm-plugin
#
# ### Public Variables
#
# * `RVM_HOME`; the home directory for RVM.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

rvm_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save rvm RVM_HOME
    export RVM_HOME="${RVM_HOME:-${HOME}/.rvm}"

    @zplugins_add_to_path rvm "${RVM_HOME}/bin"
}

# @internal
rvm_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore rvm RVM_HOME
}
