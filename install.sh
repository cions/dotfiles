#!/bin/sh

current_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")"; pwd -P)"

pushd -- "${current_dir}" >/dev/null

for name in *; do
    [[ "${name}" == "install.sh" || "${name}" == .* ]] && continue
    rm -rf "${HOME}/.${name}"
    ln -sfT "${current_dir}/${name}" "${HOME}/.${name}"
done

popd >/dev/null

unset name current_dir
