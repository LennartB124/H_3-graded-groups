### Must be loaded after H3-roots.g.

### In the following comments, we denote by R the polynomial ring over the integers in infinitely many variables. We construct root homomorphisms of a simply connected Chevalley group of type D6 over R and the root homomorphisms of the corresponding H3-grading which is obtained by folding.
### Mathematical details: Denote by L the Lie algebra o_12 over the complex numbers, which is semisimple of type D6. We compute the Chevalley group corresponding to the natural representation \delta: L -> End_{12}(C) of L in the sense of e.g. Humphreys "Introduction to Lie Algebras and Representation Theory", 27.4. The lattice Z^{12} in C^{12} is admissible with respect to \delta. Using the "standard" representation of the Lie algebra L as matrices (as in D6ChevBasEl), \delta is the identity map. Further, \delta(x_alpha)^2 = 0 for all Chevalley basis elements x_alpha. Hence the root homomorphism for alpha sends r to id + r*x_alpha.

n := 6;
oneR := One(PolynomialRing(Integers, 1));

## --- The root homomorphisms for D6 and H3 ---

# D6Root: Root in D6.
# Output: The element x_D6Root for a fixed Chevalley basis of the Lie algebra of D6.
D6ChevBasEl := function(D6Root)
	local result, posPositions, negPositions, i, j;
	result := NullMat(2*n, 2*n, Integers);
	# List of indices where D6Root has value 1 or -1.
	posPositions := Positions(D6Root, 1);
	negPositions := Positions(D6Root, -1);
	if IsEmpty(negPositions) then
		# D6Root is of the form e_i + e_j
		i := posPositions[1];
		j := posPositions[2];
		result[i][n+j] := 1;
		result[j][n+i] := -1;
	elif IsEmpty(posPositions) then
		# D6Root is of the form -e_i - e_j
		i := negPositions[1];
		j := negPositions[2];
		result[n+j][i] := 1;
		result[n+i][j] := -1;
	else
		# D6Root is of the form e_i - e_j
		i := posPositions[1];
		j := negPositions[1];
		result[i][j] := 1;
		result[n+j][n+i] := -1;
	fi;
	return result;
end;

# D6Root: Root in D6.
# r: Element of R.
# Output: The image of r in the simply connected Chevalley group of type D6 under the root homomorphism for D6Root.
D6RootHom := function(D6Root, r)
	return IdentityMat(2*n, PolynomialRing(Integers, 1)) + r*D6ChevBasEl(D6Root);
end;

# H3Root: Root in H3.
# s: Element of R x R.
# Output: The image of s under the root homomorphism for H3Root in the H3-graded group obtained by folding.
H3RootHom := function(H3Root, s)
	local preimage, D6RootShort, D6RootLong;
	preimage := FoldingPreimage(H3Root);
	D6RootShort := preimage[1]; # projW2 of this root is short in GH3
	D6RootLong := preimage[2];
	if H3Root in [ H3Sim[1], -H3Sim[1] ] then
		# "Twist" the root homomorphism for H3Sim[1] and -H3Sim[1]
		return D6RootHom(D6RootShort, s[1]) * D6RootHom(D6RootLong, -s[2]);
	else
		return D6RootHom(D6RootShort, s[1]) * D6RootHom(D6RootLong, s[2]);
	fi;
end;

# H3Root: Root in H3.
# s: Invertible element of R x R.
# Output: The corresponding H3Root-Weyl element in the H3-grading.
H3WeylEl := function(H3Root, s)
	local sInv;
	sInv := [ s[1]^-1, s[2]^-1 ];
	return H3RootHom(-H3Root, -sInv) * H3RootHom(H3Root, s) * H3RootHom(-H3Root, -sInv);
end;

H3StandardWeyl := function(H3Root)
	return H3WeylEl(H3Root, [ oneR, oneR ]);
end;

## --- Computation of the parity map for H3 ---

# alpha, delta: Roots in H3.
# Output: A tuple (a, b) in { +-1 }^2 s.t. H3RootHom(alpha, [ r, s ])^{H3StandardWeyl(delta)} = H3RootHom(refl(delta, alpha), [ ar, bs ]) for all r, s in R.
H3Parity := function(alpha, delta)
	local w, x1, x2, gamma, conj;
	w := H3StandardWeyl(delta);
	x1 := Indeterminate(Integers, 1);
	x2 := Indeterminate(Integers, 2);
	gamma := refl(delta, alpha);
	conj := w^-1 * H3RootHom(alpha, [x1, x2]) * w;
	if conj = H3RootHom(gamma, [-x1, -x2]) then
		return [ -1, -1 ];
	elif conj = H3RootHom(gamma, [x1, x2]) then
		return [ 1, 1 ];
	elif conj = H3RootHom(gamma, [-x1, x2]) then
		return [ -1, 1 ];
	elif conj = H3RootHom(gamma, [x1, -x2]) then
		return [ 1, -1];
	else
		return fail;
	fi;
end;

# alpha: Root in H3.
# deltaList: List of roots in H3.
# Output: The parity of w_{deltaList[1]} ... w_{deltaList[k]} on alpha.
H3ParityProd := function(alpha, deltaList)
	local result, basRoot, delta, par;
	result := [ 1, 1 ];
	basRoot := alpha;
	for delta in deltaList do
		par := H3Parity(basRoot, delta);
		result[1] := result[1] * par[1];
		result[2] := result[2] * par[2];
		basRoot := refl(delta, basRoot);
	od;
	return result;
end;