/-
Copyright (c) 2015 Nathaniel Thomas. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nathaniel Thomas, Jeremy Avigad

Modules prod vector spaces over a ring.

(We use "left_module," which is more precise, because "module" is a keyword.)
-/
import algebra.field ..move_to_lib
open is_trunc pointed function sigma eq algebra

structure has_scalar [class] (F V : Type) :=
(smul : F → V → V)

infixl ` • `:73 := has_scalar.smul

/- modules over a ring -/

namespace left_module

structure left_module (R M : Type) [ringR : ring R] extends has_scalar R M, ab_group M renaming
  mul→add mul_assoc→add_assoc one→zero one_mul→zero_add mul_one→add_zero inv→neg
  mul_left_inv→add_left_inv mul_comm→add_comm :=
(smul_left_distrib : Π (r : R) (x y : M), smul r (add x y) = (add (smul r x) (smul r y)))
(smul_right_distrib : Π (r s : R) (x : M), smul (ring.add _ r s) x = (add (smul r x) (smul s x)))
(mul_smul : Π r s x, smul (mul r s) x = smul r (smul s x))
(one_smul : Π x, smul one x = x)

/- we make it a class now (and not as part of the structure) to avoid
  left_module.to_ab_group to be an instance -/
attribute left_module [class]

definition add_ab_group_of_left_module [reducible] [trans_instance] (R M : Type) [K : ring R]
  [H : left_module R M] : add_ab_group M :=
@left_module.to_ab_group R M K H

definition has_scalar_of_left_module [reducible] [trans_instance] (R M : Type) [K : ring R]
  [H : left_module R M] : has_scalar R M :=
@left_module.to_has_scalar R M K H

section left_module
  variables {R M : Type}
  variable  [ringR : ring R]
  variable  [moduleRM : left_module R M]
  include   ringR moduleRM

  -- Note: the anonymous include does not work in the propositions below.

  proposition smul_left_distrib (a : R) (u v : M) : a • (u + v) = a • u + a • v :=
  !left_module.smul_left_distrib

  proposition smul_right_distrib (a b : R) (u : M) : (a + b) • u = a • u + b • u :=
  !left_module.smul_right_distrib

  proposition mul_smul (a : R) (b : R) (u : M) : (a * b) • u = a • (b • u) :=
  !left_module.mul_smul

  proposition one_smul (u : M) : (1 : R) • u = u := !left_module.one_smul

  proposition zero_smul (u : M) : (0 : R) • u = 0 :=
  have (0 : R) • u + 0 • u = 0 • u + 0, by rewrite [-smul_right_distrib, *add_zero],
  !add.left_cancel this

  proposition smul_zero (a : R) : a • (0 : M) = 0 :=
  have a • (0:M) + a • 0 = a • 0 + 0, by rewrite [-smul_left_distrib, *add_zero],
  !add.left_cancel this

  proposition neg_smul (a : R) (u : M) : (-a) • u = - (a • u) :=
  eq_neg_of_add_eq_zero (by rewrite [-smul_right_distrib, add.left_inv, zero_smul])

  proposition neg_one_smul (u : M) : -(1 : R) • u = -u :=
  by rewrite [neg_smul, one_smul]

  proposition smul_neg (a : R) (u : M) : a • (-u) = -(a • u) :=
  by rewrite [-neg_one_smul, -mul_smul, mul_neg_one_eq_neg, neg_smul]

  proposition smul_sub_left_distrib (a : R) (u v : M) : a • (u - v) = a • u - a • v :=
  by rewrite [sub_eq_add_neg, smul_left_distrib, smul_neg]

  proposition sub_smul_right_distrib (a b : R) (v : M) : (a - b) • v = a • v - b • v :=
  by rewrite [sub_eq_add_neg, smul_right_distrib, neg_smul]
end left_module

/- vector spaces -/

structure vector_space [class] (F V : Type) [fieldF : field F]
  extends left_module F V

/- homomorphisms -/

definition is_smul_hom [class] (R : Type) {M₁ M₂ : Type} [has_scalar R M₁] [has_scalar R M₂]
  (f : M₁ → M₂) : Type :=
∀ r : R, ∀ a : M₁, f (r • a) = r • f a

definition is_prop_is_smul_hom [instance] (R : Type) {M₁ M₂ : Type} [is_set M₂]
  [has_scalar R M₁] [has_scalar R M₂] (f : M₁ → M₂) : is_prop (is_smul_hom R f) :=
begin unfold is_smul_hom, apply _ end

definition respect_smul (R : Type) {M₁ M₂ : Type} [has_scalar R M₁] [has_scalar R M₂]
    (f : M₁ → M₂) [H : is_smul_hom R f] :
  ∀ r : R, ∀ a : M₁, f (r • a) = r • f a :=
H

definition is_module_hom [class] (R : Type) {M₁ M₂ : Type}
  [has_scalar R M₁] [has_scalar R M₂] [add_group M₁] [add_group M₂]
  (f : M₁ → M₂) :=
is_add_hom f × is_smul_hom R f

definition is_add_hom_of_is_module_hom [instance] (R : Type) {M₁ M₂ : Type}
  [has_scalar R M₁] [has_scalar R M₂] [add_group M₁] [add_group M₂]
  (f : M₁ → M₂) [H : is_module_hom R f] : is_add_hom f :=
prod.pr1 H

definition is_smul_hom_of_is_module_hom [instance] {R : Type} {M₁ M₂ : Type}
  [has_scalar R M₁] [has_scalar R M₂] [add_group M₁] [add_group M₂]
  (f : M₁ → M₂) [H : is_module_hom R f] : is_smul_hom R f :=
prod.pr2 H

-- Why do we have to give the instance explicitly?
definition is_prop_is_module_hom [instance] (R : Type) {M₁ M₂ : Type}
  [has_scalar R M₁] [has_scalar R M₂] [add_group M₁] [add_group M₂]
  (f : M₁ → M₂) : is_prop (is_module_hom R f) :=
have h₁ : is_prop (is_add_hom f), from is_prop_is_add_hom f,
begin unfold is_module_hom, apply _ end

section module_hom
  variables {R : Type} {M₁ M₂ M₃ : Type}
  variables [has_scalar R M₁] [has_scalar R M₂] [has_scalar R M₃]
  variables [add_group M₁] [add_group M₂] [add_group M₃]
  variables (g : M₂ → M₃) (f : M₁ → M₂) [is_module_hom R g] [is_module_hom R f]

  proposition is_module_hom_id : is_module_hom R (@id M₁) :=
  pair (λ a₁ a₂, rfl) (λ r a, rfl)

  proposition is_module_hom_comp : is_module_hom R (g ∘ f) :=
  pair
    (take a₁ a₂, begin esimp, rewrite [respect_add f, respect_add g] end)
    (take r a, by esimp; rewrite [respect_smul R f, respect_smul R g])

  proposition respect_smul_add_smul (a b : R) (u v : M₁) : f (a • u + b • v) = a • f u + b • f v :=
  by rewrite [respect_add f, +respect_smul R f]
end module_hom

structure LeftModule (R : Ring) :=
(carrier : Type) (struct : left_module R carrier)

local attribute LeftModule.carrier [coercion]
attribute LeftModule.struct [instance]

definition pointed_LeftModule_carrier [instance] {R : Ring} (M : LeftModule R) :
  pointed (LeftModule.carrier M) :=
pointed.mk zero

definition pSet_of_LeftModule [coercion] {R : Ring} (M : LeftModule R) : Set* :=
pSet.mk' (LeftModule.carrier M)

section
  variable {R : Ring}

  structure homomorphism (M₁ M₂ : LeftModule R) : Type :=
    (fn : LeftModule.carrier M₁ → LeftModule.carrier M₂)
    (p : is_module_hom R fn)

  infix ` →lm `:55 := homomorphism

  definition homomorphism_fn [unfold 4] [coercion] := @homomorphism.fn

  definition is_module_hom_of_homomorphism [unfold 4] [instance] [priority 900]
      {M₁ M₂ : LeftModule R} (φ : M₁ →lm M₂) : is_module_hom R φ :=
  homomorphism.p φ

  section
    variables {M₁ M₂ : LeftModule R} (φ : M₁ →lm M₂)

    definition to_respect_add (x y : M₁) : φ (x + y) = φ x + φ y :=
    respect_add φ x y

    definition to_respect_smul (a : R) (x : M₁) : φ (a • x) = a • (φ x) :=
    respect_smul R φ a x

    definition is_embedding_of_homomorphism /- φ -/ (H : Π{x}, φ x = 0 → x = 0) : is_embedding φ :=
    is_embedding_of_is_add_hom φ @H

    variables (M₁ M₂)
    definition is_set_homomorphism [instance] : is_set (M₁ →lm M₂) :=
    begin
      have H : M₁ →lm M₂ ≃ Σ(f : LeftModule.carrier M₁ → LeftModule.carrier M₂),
        is_module_hom (Ring.carrier R) f,
      begin
        fapply equiv.MK,
        { intro φ, induction φ, constructor, exact p},
        { intro v, induction v with f H, constructor, exact H},
        { intro v, induction v, reflexivity},
        { intro φ, induction φ, reflexivity}
      end,
    have ∀ f : LeftModule.carrier M₁ → LeftModule.carrier M₂,
      is_set (is_module_hom (Ring.carrier R) f), from _,
    apply is_trunc_equiv_closed_rev, exact H
  end

  variables {M₁ M₂}
  definition pmap_of_homomorphism [constructor] /- φ -/ :
    pSet_of_LeftModule M₁ →* pSet_of_LeftModule M₂ :=
  have H : φ 0 = 0, from respect_zero φ,
  pmap.mk φ begin esimp, exact H end

  definition homomorphism_change_fun [constructor]
    (φ : M₁ →lm M₂) (f : M₁ → M₂) (p : φ ~ f) : M₁ →lm M₂ :=
  homomorphism.mk f
    (prod.mk
      (λx₁ x₂, (p (x₁ + x₂))⁻¹ ⬝ to_respect_add φ x₁ x₂ ⬝ ap011 _ (p x₁) (p x₂))
      (λ a x, (p (a • x))⁻¹ ⬝ to_respect_smul φ a x ⬝ ap01 _ (p x)))

  definition homomorphism_eq (φ₁ φ₂ : M₁ →lm M₂) (p : φ₁ ~ φ₂) : φ₁ = φ₂ :=
  begin
    induction φ₁ with φ₁ q₁, induction φ₂ with φ₂ q₂, esimp at p, induction p,
    exact ap (homomorphism.mk φ₂) !is_prop.elim
  end
end

end

end left_module
