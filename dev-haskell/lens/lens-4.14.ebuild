# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# ebuild generated by hackport 0.5.9999
#hackport: flags: -test-hlint,+test-hunit,+test-properties

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Lenses, Folds and Traversals"
HOMEPAGE="https://github.com/ekmett/lens/"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="amd64 x86"
IUSE="benchmark-uniplate dump-splices +inlining j old-inline-pragmas safe +test-doctests +test-templates +trustworthy"

RDEPEND=">=dev-haskell/base-orphans-0.3:=[profile?] <dev-haskell/base-orphans-1:=[profile?]
	>=dev-haskell/bifunctors-5:=[profile?] <dev-haskell/bifunctors-6:=[profile?]
	>=dev-haskell/comonad-4:=[profile?] <dev-haskell/comonad-6:=[profile?]
	>=dev-haskell/contravariant-1.3:=[profile?] <dev-haskell/contravariant-2:=[profile?]
	>=dev-haskell/distributive-0.3:=[profile?] <dev-haskell/distributive-1:=[profile?]
	>=dev-haskell/exceptions-0.1.1:=[profile?] <dev-haskell/exceptions-1:=[profile?]
	>=dev-haskell/free-4:=[profile?] <dev-haskell/free-5:=[profile?]
	>=dev-haskell/hashable-1.1.2.3:=[profile?] <dev-haskell/hashable-1.3:=[profile?]
	>=dev-haskell/kan-extensions-5:=[profile?] <dev-haskell/kan-extensions-6:=[profile?]
	>=dev-haskell/mtl-2.0.1:=[profile?] <dev-haskell/mtl-2.3:=[profile?]
	>=dev-haskell/parallel-3.1.0.1:=[profile?] <dev-haskell/parallel-3.3:=[profile?]
	>=dev-haskell/profunctors-5:=[profile?] <dev-haskell/profunctors-6:=[profile?]
	>=dev-haskell/reflection-2.1:=[profile?] <dev-haskell/reflection-3:=[profile?]
	>=dev-haskell/semigroupoids-5:=[profile?] <dev-haskell/semigroupoids-6:=[profile?]
	>=dev-haskell/semigroups-0.8.4:=[profile?] <dev-haskell/semigroups-1:=[profile?]
	>=dev-haskell/tagged-0.4.4:=[profile?] <dev-haskell/tagged-1:=[profile?]
	>=dev-haskell/text-0.11:=[profile?] <dev-haskell/text-1.3:=[profile?]
	>=dev-haskell/transformers-0.2:=[profile?] <dev-haskell/transformers-0.6:=[profile?]
	>=dev-haskell/transformers-compat-0.4:=[profile?] <dev-haskell/transformers-compat-1:=[profile?]
	>=dev-haskell/unordered-containers-0.2.4:=[profile?] <dev-haskell/unordered-containers-0.3:=[profile?]
	>=dev-haskell/vector-0.9:=[profile?] <dev-haskell/vector-0.12:=[profile?]
	>=dev-haskell/void-0.5:=[profile?] <dev-haskell/void-1:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( >=dev-haskell/hunit-1.2
		>=dev-haskell/quickcheck-2.4
		>=dev-haskell/test-framework-0.6
		>=dev-haskell/test-framework-hunit-0.2
		>=dev-haskell/test-framework-quickcheck2-0.2
		>=dev-haskell/test-framework-th-0.2
		test-doctests? ( >=dev-haskell/doctest-0.9.1
					dev-haskell/generic-deriving
					dev-haskell/nats
					>=dev-haskell/semigroups-0.9
					>=dev-haskell/simple-reflect-0.3.1 ) )
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag benchmark-uniplate benchmark-uniplate) \
		$(cabal_flag dump-splices dump-splices) \
		$(cabal_flag inlining inlining) \
		$(cabal_flag j j) \
		$(cabal_flag old-inline-pragmas old-inline-pragmas) \
		$(cabal_flag safe safe) \
		$(cabal_flag test-doctests test-doctests) \
		--flag=-test-hlint \
		--flag=test-hunit \
		--flag=test-properties \
		$(cabal_flag test-templates test-templates) \
		$(cabal_flag trustworthy trustworthy)
}
