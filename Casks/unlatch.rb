# SPDX-License-Identifier: GPL-3.0-or-later
# Template: Scripts/release.sh fills in 1.0.0-beta.3 and 7bade43cbcb7c136185a5bab1de43aa0b67905ccbd85bb3948d200a1cabe430f (plan Step 18, D-69).
cask "unlatch" do
  version "1.0.0-beta.3"
  sha256 "7bade43cbcb7c136185a5bab1de43aa0b67905ccbd85bb3948d200a1cabe430f"

  url "https://github.com/Ramanan-Bala/unlatch/releases/download/v#{version}/Unlatch-#{version}.dmg"
  name "Unlatch"
  desc "Mount NTFS volumes read-write through macFUSE"
  homepage "https://github.com/Ramanan-Bala/unlatch"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  # macFUSE is installed separately and never bundled: its license forbids redistribution.
  depends_on cask: "macfuse"
  depends_on :macos

  app "Unlatch.app"
  binary "#{appdir}/Unlatch.app/Contents/Helpers/unlatch"

  uninstall early_script: {
              executable:   "#{appdir}/Unlatch.app/Contents/Helpers/unlatch",
              args:         ["unmount", "--all"],
              must_succeed: false,
            },
            launchctl:    "io.github.ramanan-bala.unlatch.helper",
            quit:         "io.github.ramanan-bala.Unlatch",
            delete:       [
              "/Library/LaunchDaemons/io.github.ramanan-bala.unlatch.helper.plist",
              "/Library/PrivilegedHelperTools/Unlatch Helper",
              "/Library/PrivilegedHelperTools/io.github.ramanan-bala.unlatch.helper",
            ]

  zap trash: [
    "~/Library/Application Support/Unlatch",
    "~/Library/Preferences/io.github.ramanan-bala.Unlatch.plist",
  ]

  caveats <<~EOS
    Unlatch is not signed with an Apple Developer ID. If macOS refuses to open it, open it once
    with a right-click on Unlatch in Applications > Open, or allow it in System Settings >
    Privacy & Security > "Open Anyway". Until then macOS also stops the `unlatch` command.

    macFUSE's kernel extension must be allowed once (Recovery > Reduced Security, then Allow in
    System Settings > Privacy & Security); Unlatch's setup window walks through it:
    https://github.com/Ramanan-Bala/unlatch#one-time-setup
    Uninstalling Unlatch leaves macFUSE installed (brew uninstall --cask macfuse removes it).
  EOS
end
