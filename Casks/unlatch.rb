# SPDX-License-Identifier: GPL-3.0-or-later
# Template: Scripts/release.sh fills in 1.0.0-beta.1 and 9c5e9d57bbbf4ca2c07e0c8c8b999b4b4812c0d5e98853c3062730eed321e78d (plan Step 18, D-69).
cask "unlatch" do
  version "1.0.0-beta.1"
  sha256 "9c5e9d57bbbf4ca2c07e0c8c8b999b4b4812c0d5e98853c3062730eed321e78d"

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
              "/Library/PrivilegedHelperTools/io.github.ramanan-bala.unlatch.helper",
            ]

  zap trash: [
    "~/Library/Application Support/Unlatch",
    "~/Library/Preferences/io.github.ramanan-bala.Unlatch.plist",
  ]

  caveats <<~EOS
    Unlatch is not signed with an Apple Developer ID. If macOS refuses to open it, open it once
    with a right-click on Unlatch in Applications > Open, or allow it in System Settings >
    Privacy & Security > "Open Anyway".

    macFUSE's kernel extension must be allowed once (Recovery > Reduced Security, then Allow in
    System Settings > Privacy & Security); Unlatch's setup window walks through it:
    https://github.com/Ramanan-Bala/unlatch#one-time-setup
    Uninstalling Unlatch leaves macFUSE installed (brew uninstall --cask macfuse removes it).
  EOS
end
