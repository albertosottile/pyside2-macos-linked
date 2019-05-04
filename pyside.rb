class Pyside < Formula
  desc "Official Python bindings for Qt"
  homepage "https://wiki.qt.io/Qt_for_Python"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.12.3-src/pyside-setup-everywhere-src-5.12.3.tar.xz"
  sha256 "4f7aab7d4bbaf1b3573cc989d704e87b0de55cce656ae5e23418a88baa4c6842"

  depends_on "cmake" => :build
  depends_on "llvm" => :build
  depends_on "python"
  depends_on "qt"

  def install
    ENV.remove "HOMEBREW_LIBRARY_PATHS", Formula["llvm"].opt_lib

    args = %W[
      --ignore-git
      --parallel=#{ENV.make_jobs}
      --module-subset=Core,Gui,Widgets
      --reuse-build
      --install-scripts #{bin}
    ]

    xy = Language::Python.major_minor_version "python3"

    system "python3", *Language::Python.setup_install_args(prefix),
           "--install-lib", lib/"python#{xy}/site-packages", *args,
           "--internal-build-type=shiboken2"

    system "python3", *Language::Python.setup_install_args(prefix),
           "--install-lib", lib/"python#{xy}/site-packages", *args,
           "--internal-build-type=pyside2"

    lib.install_symlink Dir.glob(lib/"python#{xy}/site-packages/PySide2/*.dylib")
    lib.install_symlink Dir.glob(lib/"python#{xy}/site-packages/shiboken2/*.dylib")
  end

  test do
    ["python3"].each do |python|
      system python, "-c", "import PySide2"
      %w[
        Core
        Gui
        Widgets
      ].each { |mod| system python, "-c", "import PySide2.Qt#{mod}" }
    end
  end
end
