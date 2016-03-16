(*

  Copyright 2014 Cornell University

  This file is part of VPrl (the Verified Nuprl project).

  VPrl is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VPrl is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VPrl.  If not, see <http://www.gnu.org/licenses/>.


  Website: http://nuprl.org/html/verification/
  Authors: Abhishek Anand & Vincent Rahli

*)


Require Export UsefulTypes.
Require Export bin_rels.

Notation LIn := (List.In).
(**
uncomment this and remove the line above if [univ]:=Type

Fixpoint LIn {A : Type} (a:A) (l:list A) : [univ] :=
  match l with
    | nil => False
    | b :: m => (b = a) [+] LIn a m
  end.

Definition In := 9.

*)



Fixpoint ball (l : list bool) : bool :=
  match l with
    | [] => true
    | x :: xs => andb x (ball xs)
  end.

Lemma ball_true :
  forall l,
    ball l = true <=> (forall x,  LIn x l -> x = true).
Proof.
  induction l; simpl; sp.
  rw andb_eq_true.
  trw IHl; split; sp.
Qed.

Lemma ball_map_true :
  forall A,
  forall f : A -> bool,
  forall l : list A,
    ball (map f l) = true <=> forall x,  LIn x l -> f x = true.
Proof.
  induction l; simpl; sp.
  trw andb_eq_true.
  trw IHl; split; sp; subst; sp.
Qed.

Lemma remove_trivial :
  forall T x eq,
  forall l : list T,
    (! LIn x l)
      -> remove eq x l = l.
Proof.
  induction l as [| a l]; simpl; intro H; sp.
  cases_if as Heq.
  destruct H. left. auto.
  f_equal.
  rewrite IHl.  auto.
  introv Hlin. apply H. auto.
Qed.

(** l \ lr -- removes the elements of lr from l  *)
Fixpoint diff {T} (eqd:Deq T) (lr:list T) (l:list T) : list T :=
  match lr with
    | [] => l
    | h::t => diff eqd t (remove eqd h l)
  end.

Lemma diff_nil :
  forall T eq, forall l : list T, diff eq l [] = [].
Proof.
  induction l; simpl; auto.
Qed.

Hint Rewrite diff_nil.

Lemma in_remove :
  forall T x y eq, forall l : list T,
    LIn x (remove eq y l) <=> (~ x = y) # LIn x l.
Proof.
  induction l; simpl.
  split; sp.
  remember (eq y a); destruct s; subst; allsimpl; allrw IHl; split; sp; subst; sp.
Qed.

Lemma in_diff :
  forall T,
  forall l1 l2 : list T,
  forall x eq,
    LIn x (diff eq l1 l2)
    <=>
    (LIn x l2  # (! LIn x l1)).
Proof.
  induction l1; simpl; sp.
  split; sp. introv. auto.
  trw IHl1; trw in_remove; split; sp; auto.
Qed.

Lemma remove_app :
  forall T eq x,
  forall l1 l2 : list T,
    remove eq x (l1 ++ l2) = remove eq x l1 ++ remove eq x l2.
Proof.
  induction l1; simpl; sp.
  destruct (eq x a); subst; rewrite IHl1; auto.
Qed.

Lemma remove_comm :
  forall T eq,
  forall l : list T,
  forall x y,
    remove eq x (remove eq y l) = remove eq y (remove eq x l).
Proof.
  induction l; simpl; sp.
  destruct (eq y a); subst; destruct (eq x a); subst; simpl; auto.
  destruct (eq a a).
  rewrite IHl; auto.
  provefalse; apply n0; auto.
  destruct (eq a a).
  rewrite IHl; auto.
  provefalse; apply n0; auto.
  destruct (eq x a); auto.
  provefalse; apply n0; auto.
  destruct (eq y a); auto.
  provefalse; apply n; auto.
  rewrite IHl; auto.
Qed.

Lemma diff_remove :
  forall T eq,
  forall l1 l2 : list T,
  forall x,
    diff eq l1 (remove eq x l2) = remove eq x (diff eq l1 l2).
Proof.
  induction l1; simpl; sp.
  repeat (rewrite IHl1).
  rewrite remove_comm; auto.
Qed.

Lemma diff_comm :
  forall T eq,
  forall l1 l2 l3 : list T,
    diff eq l1 (diff eq l2 l3) = diff eq l2 (diff eq l1 l3).
Proof.
  induction l1; simpl; sp.
  rewrite <- diff_remove.
  rewrite IHl1; auto.
Qed.

Lemma diff_app_r :
  forall T eq,
  forall l1 l2 l3 : list T,
    diff eq l1 (l2 ++ l3) = diff eq l1 l2 ++ diff eq l1 l3.
Proof.
  induction l1; simpl; sp.
  rewrite remove_app.
  rewrite IHl1; auto.
Qed.

Lemma diff_app_l :
  forall T eq,
  forall l1 l2 l3 : list T,
    diff eq l1 (diff eq l2 l3) = diff eq (l1 ++ l2) l3.
Proof.
  induction l1; simpl; sp.
  repeat (rewrite diff_remove).
  rewrite IHl1; auto.
Qed.

Lemma remove_repeat :
  forall T eq x,
  forall l : list T,
    remove eq x l = remove eq x (remove eq x l).
Proof.
  induction l; simpl; sp.
  destruct (eq x a); subst; auto.
  simpl.
  destruct (eq x a).
  provefalse; apply n; auto.
  rewrite <- IHl; auto.
Qed.

Lemma diff_repeat :
  forall T eq,
  forall l1 l2 : list T,
    diff eq l1 l2 = diff eq l1 (diff eq l1 l2).
Proof.
  induction l1; simpl; sp.
  repeat (rewrite diff_remove).
  rewrite <- remove_repeat.
  rewrite <- IHl1; auto.
Qed.

Lemma remove_dup :
  forall T eq,
  forall l1 l2 : list T,
  forall x,
    LIn x l1
    -> diff eq l1 l2 = remove eq x (diff eq l1 l2).
Proof.
  induction l1; simpl; sp; subst.
  rewrite diff_remove.
  rewrite <- remove_repeat; auto.
Qed.

Lemma diff_move :
  forall T eq,
  forall l1 l2 l3 : list T,
  forall x,
    diff eq (l1 ++ x :: l2) l3 = diff eq (x :: l1 ++ l2) l3.
Proof.
  induction l1; simpl; sp.
  rewrite IHl1; simpl.
  rewrite remove_comm; auto.
Qed.

Lemma diff_dup :
  forall T eq,
  forall l1 l2 l3 : list T,
  forall x,
    LIn x (l1 ++ l2)
    -> diff eq (l1 ++ l2) l3 = diff eq (l1 ++ x :: l2) l3.
Proof.
  induction l1; simpl; sp; subst.
  rewrite diff_remove.
  apply remove_dup; auto.
  rewrite diff_move; simpl.
  rewrite <- remove_repeat; auto.
Qed.

Lemma in_app_iff :
  forall A l l' (a:A),
    LIn a (l++l') <=> (LIn a l) [+] (LIn a l').
Proof.
  induction l as [| a l]; introv; simpl; try (rw IHl); split; sp.
Qed.

Lemma in_map_iff :
  forall (A B : Type) (f : A -> B) l b,
    LIn b (map f l) <=> {a : A $ LIn a l # b = f a}.
Proof.
  induction l; simpl; sp; try (complete (split; sp)).
  trw IHl; split; sp; subst; sp.
  exists a; sp.
  exists a0; sp.
  right; exists a0; sp.
Qed.

Lemma diff_dup2 :
  forall T eq,
  forall l1 l2 l3 : list T,
  forall x,
    LIn x l1
    -> diff eq (l1 ++ l2) l3 = diff eq (l1 ++ x :: l2) l3.
Proof.
  intros; apply diff_dup.
  apply in_app_iff; left; auto.
Qed.

Definition null {T} (l : list T) := forall x, !LIn x l.

Lemma null_nil : forall T, null ([] : list T).
Proof.
  unfold null; sp.
Qed.

Hint Immediate null_nil.

Lemma null_nil_iff : forall T, null ([] : list T) <=> True.
Proof.
  split; sp; apply null_nil.
Qed.

Hint Rewrite null_nil_iff.

Lemma null_diff :
  forall T,
  forall eq : Deq T,
  forall l1 l2 : list T,
    null (diff eq l1 l2) <=> forall x, LIn x l2 -> LIn x l1.
Proof.
  induction l1; simpl; sp.
  trw IHl1; sp; split; sp.
  assert ({a = x} + {a <> x}) by auto; sp.
  right; apply_hyp.
  trw in_remove; sp.
  alltrewrite in_remove; sp.
  apply_in_hyp p; sp; subst; sp.
Qed.

Lemma null_iff_nil : forall T, forall l : list T, null l <=> l = [].
Proof.
  induction l; unfold null; simpl; split; sp.
  assert ((a = a) [+] LIn a l) by (left; auto).
  apply_in_hyp p; sp.
Qed.

Lemma null_cons :
  forall T x,
  forall l : list T,
    !( null (x :: l)).
Proof.
  unfold null; sp.
  assert (LIn x (x :: l)) by (simpl; left; auto).
  apply_in_hyp p; sp.
Qed.
Hint Immediate null_cons.

Lemma null_app :
  forall T,
  forall l1 l2 : list T,
    null (l1 ++ l2) <=> null l1 # null l2.
Proof.
  induction l1; simpl; sp; split; sp;
  try (apply null_nil);
  try(apply null_cons in H); sp;
  try(apply null_cons in H0); sp.
Qed.

Lemma null_map :
  forall A B,
  forall f : A -> B,
  forall l : list A,
    null (map f l) <=> null l.
Proof.
  induction l; simpl; sp; split; sp;
  try (apply null_nil);
  apply null_cons in H; sp.
Qed.


Definition nullb {T} (l : list T) := if l then true else false.

Lemma assert_nullb :
  forall T,
  forall l : list T,
    assert (nullb l) <=> null l.
Proof.
  destruct l; simpl; split; sp.
  apply not_assert in H; sp.
  apply null_cons in H; sp.
Qed.

Definition subsetb {T} (eq : Deq T) (l1 l2 : list T) : bool :=
  nullb (diff eq l2 l1).

Definition eqsetb {T} (eq : Deq T) (l1 l2 : list T) : bool :=
  subsetb eq l1 l2 && subsetb eq l2 l1.

Lemma assert_subsetb :
  forall T eq,
  forall l1 l2 : list T,
    assert (subsetb eq l1 l2)
    <=>
    forall x, LIn x l1 -> LIn x l2.
Proof.
  sp; unfold subsetb.
  trw assert_nullb; trw null_diff; split; sp.
Qed.

Lemma assert_eqsetb :
  forall T eq,
  forall l1 l2 : list T,
    assert (eqsetb eq l1 l2)
    <=>
    forall x,  LIn x l1 <=>  LIn x l2.
Proof.
  sp; unfold eqsetb; trw assert_of_andb;
  repeat (trw assert_subsetb); repeat (split; sp);
  apply_in_hyp p; auto.
Qed.

Fixpoint beq_list {A} (eq : Deq A) (l1 l2 : list A) : bool :=
  match l1, l2 with
    | [], [] => true
    | [], _ => false
    | _, [] => false
    | x :: xs, y :: ys => if eq x y then beq_list eq xs ys else false
  end.

Lemma beq_list_refl :
  forall A eq,
  forall l : list A,
    beq_list eq l l = true.
Proof.
  induction l; simpl; sp.
  destruct (eq a a); auto.
Qed.

Lemma assert_beq_list :
  forall A eq,
  forall l1 l2 : list A,
    assert (beq_list eq l1 l2) <=> l1 = l2.
Proof.
  induction l1; destruct l2; simpl; split; sp; try (complete (inversion H)).
  destruct (eq a a0); subst.
  f_equal. apply IHl1; auto. 
  inversion H.
  inversion H; subst.
  destruct (eq a0 a0); subst; sp.
  apply IHl1; sp.
Qed.

Lemma eq_lists :
  forall A (l1 l2 : list A) x,
    l1 = l2
    <=>
    (
      length l1 = length l2
       #
      forall n, nth n l1 x = nth n l2 x
    ).
Proof.
  induction l1; sp; destruct l2; sp; split; allsimpl; sp;
  try(inversion H);try(inversion H0); subst; sp.
  gen_some 0; subst.
  assert (l1 = l2) as eq; try (rewrite eq; sp).
  apply IHl1 with (x := x); sp.
  gen_some (S n); sp.
Qed.

(*
Fixpoint memberb' {A} (eq : Deq A) (x : A) (l : list A) : {  LIn x l } + { !  LIn x l} :=
  match l return {  LIn x l } + { !  LIn x l} with
  | [] => right (fun x => x)
  | y :: ys =>
    match eq y x with
      | left e => left (or_introl e)
      | right _ =>
        match memberb' eq x ys with
          | left x => left (or_intror x)
          | right y => right y
        end
    end
  end.
*)

Fixpoint memberb {A : Type} (eq : Deq A) (x : A) (l : list A) : bool :=
  match l with
    | [] => false
    | y :: ys => if eq y x then true else memberb eq x ys
  end.

Theorem assert_memberb :
  forall {T:Type} {eq : Deq T} (a:T) (l: list T),
    assert (memberb eq a l) <=>  LIn a l.
Proof.
  intros. induction l. simpl.
  try (unfold assert; repeat split; intros Hf; auto ; inversion Hf).
  simpl. destruct (eq a0 a) as [Heq | Hneq]. subst. unfold assert; repeat split; auto.
  repeat split; intros Hlr. right. apply IHl; auto.
  destruct Hlr as [Heq  | Hin].  apply Hneq in Heq. contradiction.
  apply IHl; auto.
Qed.

Lemma memberb_app :
  forall A eq x,
  forall l1 l2 : list A,
    memberb eq x (l1 ++ l2) = memberb eq x l1 || memberb eq x l2.
Proof.
  induction l1; simpl; sp.
  destruct (eq a x); sp.
Qed.

Lemma in_app_deq :
  forall A l1 l2 (a : A) (deq : Deq A),
    LIn a (l1 ++ l2) -> (LIn a l1 + LIn a l2).
Proof.
  introv deq i.
  rw <- (@assert_memberb A deq) in i.
  rw memberb_app in i.
  apply assert_orb in i; sp; allrw (@assert_memberb A deq); sp.
Qed.

Lemma diff_cons_r :
  forall A eq x,
  forall l1 l2 : list A,
    diff eq l1 (x :: l2)
    = if memberb eq x l1
      then diff eq l1 l2
      else x :: diff eq l1 l2.
Proof.
  induction l1; simpl; sp.
  destruct (eq a x); subst; auto.
Qed.

Lemma diff_cons_r_ni :
  forall A eq x,
  forall l1 l2 : list A,
    !LIn x l2 -> diff eq (x :: l1) l2 = diff eq l1 l2.
Proof.
  induction l1; simpl; sp.
  induction l2; allsimpl; allrw not_over_or; sp.
  destruct (eq x a); try subst; sp.
  allrw; sp.
  rw (remove_trivial A x); sp.
Qed.

Fixpoint maxl (ts : list nat) : nat :=
  match ts with
  | nil => 0
  | n :: ns => max n (maxl ns)
  end.

Lemma maxl_prop :
  forall nats n,
     LIn n nats -> n <= maxl nats.
Proof.
  induction nats; simpl; sp; subst.
  apply max_prop1.
  allapply IHnats.
  assert (maxl nats <= max a (maxl nats)) by apply max_prop2.
  omega.
Qed.

Fixpoint addl (ts : list nat) : nat :=
  match ts with
  | nil => 0
  | n :: ns => n + (addl ns)
  end.

Theorem lin_flat_map :
  forall (A B : Type) (f : A -> list B) (l : list A) (y : B),
    LIn y (flat_map f l)
        <=>
        {x : A $ LIn x l # LIn y (f x)}.
Proof.
  induction l; simpl; sp.
  split; sp.
  trw in_app_iff.
  trw IHl.
  split; sp; subst; sp.
  exists a; sp.
  exists x; sp.
  right; exists x; sp.
Qed.

Theorem flat_map_empty:
 forall A B (ll:list A)  (f: A -> list B) , flat_map f ll =[]
   <=> forall a,  LIn a ll -> f a =[].
Proof. sp_iff Case.
 Case "->".
   intros Hmap a Hin; remember (f a) as fa; destruct fa.
   auto. assert ({a: A $ LIn a ll # LIn b (f a)}) as Hass;
    try (apply  lin_flat_map in Hass;
    rewrite Hmap in Hass; inversion Hass).
    exists a. (split; auto).  rewrite <- Heqfa.
   constructor; auto.
 Case "<-".
   intros Hin.
   remember (flat_map f ll) as flat; destruct flat ;auto.
   assert ( LIn b (flat_map f ll)) as Hinbf by
   (rewrite  <- Heqflat; constructor; auto).
   apply lin_flat_map in Hinbf. exrepnd.
   apply Hin in Hinbf1.
   rewrite Hinbf1 in Hinbf0.
   inversion Hinbf0.
Qed.

Lemma flat_map_map :
  forall A B C ,
  forall f : B -> list C,
  forall g : A -> B,
  forall l : list A,
    flat_map f (map g l) = flat_map (compose f g) l.
Proof.
  induction l; simpl; sp.
  rewrite IHl.
  unfold compose; auto.
Qed.

Lemma map_map :
  forall A B C ,
  forall f : B -> C,
  forall g : A -> B,
  forall l : list A,
    map f (map g l) = map (compose f g) l.
Proof.
  induction l; simpl; sp.
  rewrite IHl.
  unfold compose; auto.
Qed.

Lemma eq_flat_maps :
  forall A B,
  forall f g : A -> list B,
  forall l : list A,
    (forall x,  LIn x l -> f x = g x)
    -> flat_map f l = flat_map g l.
Proof.
  induction l; simpl; sp.
  assert (f a = g a).
  apply H; left; auto.
  rewrite H0.
  assert (flat_map f l = flat_map g l).
  rewrite IHl; auto.
  rewrite H1; auto.
Qed.

Lemma eq_maps :
  forall A B,
  forall f g : A -> B,
  forall l : list A,
    (forall x,  LIn x l -> f x = g x)
    -> map f l = map g l.
Proof.
  induction l; simpl; sp.
  assert (f a = g a).
  apply H; left; auto.
  rewrite H0.
  rewrite IHl; auto.
Qed.
Lemma in_nth :
  forall T a (l:list T),
     LIn a l
    -> {n : nat $ (n < length l) # a = nth n l a}.
Proof.
  intros ? ? ?. induction l; intros Hin.
  - simpl in Hin. contradiction.
  - simpl in Hin. dorn Hin.
     + intros. subst. exists 0. split; auto. simpl. omega.
     + intros. apply IHl in Hin. exrepnd.
        simpl.
         exists (S n) ;split ; try (simpl; omega).
         fold (app [a0] l);sp.
Qed.

(* stronger one above : no need for decidability
Lemma in_nth :
  forall T a (l:list T),
    Deq T
    ->  LIn a l
    -> {n : nat $ (n < length l) # a = nth n l a}.
Proof.
  intros ? ? ? deq. induction l; intros Hin.
 - simpl in Hin. contradiction.
 - case (deq a a0).
   + intros. subst. exists 0. split; auto. simpl. omega.
   + intros Hneq. simpl in Hin.
     destruct Hin as [Heq  | Hin].
     * symmetry in Heq. apply Hneq in Heq. contradiction.
     * apply IHl in Hin. clear Hneq. destruct Hin as [m Hp]. repnd.
       exists (S m) ;split ; try (simpl; omega).
       fold (app [a0] l).
       rewrite app_nth2. simpl.  assert (m-0 =m) as Hrew by omega.
       rewrite Hrew. auto. simpl. omega.
Qed.
*)

Lemma nth_in :
  forall A n (l : list A) d,
    n < length l
    -> LIn (nth n l d) l.
Proof.
  intros A n l d H; revert n H.
  induction l; simpl; sp.
  destruct n; sp.
  allapply S_lt_inj; sp.
Qed.

Fixpoint snoc {X:Type} (l:list X) (v:X) : (list X) :=
  match l with
  | nil      => cons v nil
  | cons h t => cons h (snoc t v)
  end.

Lemma length_snoc :
  forall T,
  forall n : T,
  forall l : list T,
    length (snoc l n) = S (length l).
Proof.
  intros; induction l; simpl; sp.
Qed.

Lemma snoc_as_append :
  forall T, forall l : list T, forall n,
    snoc l n = l ++ [n].
Proof.
  intros; induction l; simpl; sp.
  rewrite IHl; sp.
Qed.

Lemma snoc_append_r :
  forall T, forall l1 l2 : list T, forall v : T,
    (snoc l1 v) ++ l2 = l1 ++ (v :: l2).
Proof.
  intros; induction l1; simpl; sp.
  rewrite IHl1; sp.
Qed.

Lemma snoc_append_l :
  forall T, forall l1 l2 : list T, forall v : T,
    l2 ++ (snoc l1 v) = snoc (l2 ++ l1) v.
Proof.
  intros; induction l2; simpl; sp.
  rewrite IHl2; sp.
Qed.

Lemma in_snoc :
  forall T,
  forall l : list T,
  forall x y : T,
     LIn x (snoc l y) <=> (LIn x l [+] x = y).
Proof.
  induction l; simpl; sp.
  split; sp.
  trw IHl.
  apply sum_assoc.
Qed.

Hint Rewrite in_snoc.

Lemma snoc_cases :
  forall T,
  forall l : list T,
    l = [] [+] {a : T $ {k : list T $ l = snoc k a}}.
Proof.
  induction l.
  left; auto.
  sp; subst.
  right; exists a; exists (@nil T); simpl; auto.
  right.
  exists a0; exists (a :: k); simpl; auto.
Qed.

Lemma snoc_inj :
  forall T,
  forall l1 l2 : list T,
  forall x1 x2 : T,
    snoc l1 x1 = snoc l2 x2 -> l1 = l2  #  x1 = x2.
Proof.
  induction l1; simpl; intros.
  destruct l2; simpl in H; inversion H; subst; auto.
  inversion H.
  destruct l2; simpl in H1; inversion H1.
  destruct l2; simpl in H.
  inversion H.
  destruct l1; simpl in H2; inversion H2.
  inversion H.
  apply IHl1 in H2. sp; subst; auto.
Qed.

Lemma map_snoc :
  forall A B l x,
  forall f : A -> B,
    map f (snoc l x) = snoc (map f l) (f x).
Proof.
  induction l; simpl; sp.
  rewrite IHl; sp.
Qed.

Lemma length_app :
  forall T,
  forall l1 l2 : list T,
    length (l1 ++ l2) = length l1 + length l2.
Proof.
  induction l1; simpl; sp.
Qed.

Lemma nil_snoc_false :
  forall T, forall a : list T, forall b : T, [] = snoc a b -> False.
Proof.
  intros.
  assert (length ([] : list T) = length (snoc a b)).
  rewrite H; auto.
  simpl in H0.
  rewrite length_snoc in H0.
  inversion H0.
Qed.


Definition subset {T} (l1 l2 : list T) :=
  forall x,  LIn x l1 ->  LIn x l2.

Lemma fold_subset :
  forall T l1 l2,
    (forall x : T,  LIn x l1 ->  LIn x l2) = subset l1 l2.
Proof. sp. Qed.

Lemma null_diff_subset :
  forall T,
  forall eq : Deq T,
  forall l1 l2 : list T,
    null (diff eq l1 l2) <=> subset l2 l1.
Proof.
  sp; apply null_diff; unfold subset; split; sp.
Qed.

Lemma subsetb_subset :
  forall T eq,
  forall l1 l2 : list T,
    assert (subsetb eq l1 l2) <=> subset l1 l2.
Proof.
  intros.
  apply assert_subsetb; unfold subset; split; sp.
Qed.

Lemma subset_refl :
  forall T,
  forall l : list T,
    subset l l.
Proof.
  unfold subset; sp.
Qed.

Hint Immediate subset_refl.

Lemma subset_refl_iff :
  forall T,
  forall l : list T,
    subset l l <=> True.
Proof.
  unfold subset; sp; split; sp.
Qed.

Hint Rewrite subset_refl_iff.

Lemma subset_nil_l :
  forall T, forall s : list T, subset [] s.
Proof.
  unfold subset; simpl; sp.
Qed.

Hint Immediate subset_nil_l.

Lemma subset_nil_l_iff :
  forall T, forall s : list T, subset [] s <=> True.
Proof.
  unfold subset; simpl; sp; split; sp.
Qed.

Hint Rewrite subset_nil_l_iff.

(* same as subset_nil_l *)
Lemma nil_subset :
  forall T, forall l : list T, subset [] l.
Proof.
  auto.
Qed.

(* same as subset_nil_l_iff *)
Lemma nil_subset_iff :
  forall T,
  forall l : list T,
    subset [] l <=> True.
Proof.
  sp; autorewrite with core; sp.
Qed.

Lemma cons_subset :
  forall T,
  forall x : T,
  forall l1 l2 : list T,
    subset (x :: l1) l2
    <=>  LIn x l2  #  subset l1 l2.
Proof.
  unfold subset; simpl; sp; split; sp; subst; auto.
Qed.

Tactic Notation "trewritec" constr(H) :=
       build_and_rewrite H.

Lemma singleton_subset :
  forall T,
  forall x : T,
  forall l : list T,
    subset [x] l <=>  LIn x l.
Proof.
  intros.
  remember (cons_subset T x [] l) as Htr.
  trewrite Htr.
  split; sp.
Qed.


Lemma app_subset :
  forall T,
  forall l1 l2 l3 : list T,
    subset (l1 ++ l2) l3 <=> subset l1 l3  #  subset l2 l3.
Proof.
  induction l1; simpl; sp; try(split; sp; fail).
  trw cons_subset. trw cons_subset.  
  split; introv Hlin; repnd; 
  try(trw IHl1); try(trw_h IHl1  Hlin; repnd);
  repeat(auto;split;auto).
Qed.

Lemma subset_trans :
  forall T,
  forall l1 l2 l3 : list T,
    subset l1 l2
    -> subset l2 l3
    -> subset l1 l3.
Proof.
  unfold subset; sp.
Qed.

Lemma subset_cons_nil :
  forall T x,
  forall l : list T,
    ! subset (x :: l) [].
Proof.
  unfold subset; sp.
  assert ( LIn x (x :: l)) by (simpl; left; auto).
  apply_in_hyp p; allsimpl; sp.
Qed.

Lemma subset_cons1 :
  forall T,
  forall x : T,
  forall l1 l2 : list T,
    subset l1 l2
    -> subset l1 (x :: l2).
Proof.
  unfold subset; simpl; sp.
Qed.

Lemma subset_cons2 :
  forall T,
  forall x : T,
  forall l1 l2 : list T,
    subset l1 l2
    -> subset (x :: l1) (x :: l2).
Proof.
  unfold subset; simpl; sp.
Qed.

Lemma subset_app_r :
  forall T,
  forall l1 l2 l3 : list T,
    subset l1 l2 -> subset l1 (l2 ++ l3).
Proof.
  unfold subset; intros.
  apply (@in_app_iff T).
  left; auto.
Qed.

Lemma subset_app_l :
  forall T,
  forall l1 l2 l3 : list T,
    subset l1 l3 -> subset l1 (l2 ++ l3).
Proof.
  unfold subset; intros.
  apply in_app_iff.
  right; auto.
Qed.

Lemma subset_app :
  forall T,
  forall l1 l2 l3 : list T,
    subset (l1 ++ l2) l3 <=> subset l1 l3  #  subset l2 l3.
Proof.
  unfold subset; sp; split; sp.
  apply_hyp; apply in_app_iff; left; auto.
  apply_hyp; apply in_app_iff; right; auto.
  allrw in_app_iff; sp.
Qed.

Lemma subset_snoc_r :
  forall T x,
  forall l1 l2 : list T,
    subset l1 l2 -> subset l1 (snoc l2 x).
Proof.
  unfold subset; intros.
  apply in_snoc.
  left; auto.
Qed.

Lemma subset_snoc_l :
  forall T x,
  forall l1 l2 : list T,
    (forall y,  LIn y l1 -> y = x)
    -> subset l1 (snoc l2 x).
Proof.
  unfold subset; sp.
  apply in_snoc.
  apply_in_hyp p; sp.
Qed.

Lemma null_subset :
  forall T,
  forall l1 l2 : list T,
    subset l1 l2
    -> null l2
    -> null l1.
Proof.
  unfold subset, null; sp.
  apply_in_hyp p; sp.
Qed.

Lemma subset_cons_l :
  forall T v,
  forall vs1 vs2 : list T,
    subset (v :: vs1) vs2 <=>  LIn v vs2  #  subset vs1 vs2.
Proof.
  unfold subset; simpl; sp; split; sp; subst; auto.
Qed.

Lemma in_subset :
  forall T (s1 s2 : list T) x,
    subset s1 s2
    ->  LIn x s1
    ->  LIn x s2.
Proof.
  intros T s1 s2 x.
  unfold subset; sp.
Qed.

Lemma not_in_subset :
  forall T (s1 s2 : list T) x,
    subset s1 s2
    ->  LIn x s1
    -> !  LIn x s2
    -> False.
Proof.
  intros T s1 s2 x.
  unfold subset; sp.
Qed.



Lemma subset_flat_map :
  forall A B,
  forall f : A -> list B,
  forall l k,
    subset (flat_map f l) k
    <=>
    forall x,  LIn x l -> subset (f x) k.
Proof.
  induction l; simpl; sp.
  trw nil_subset_iff; split; sp.
  trw app_subset; split; sp; subst; sp; alltrewrite IHl; sp.
Qed.

Lemma in_deq :
  forall A,
  forall eq : Deq A,
  forall x : A,
  forall l,
     LIn x l + !LIn x l.
Proof.
  induction l; simpl; sp; try (complete (right; sp)).
  destruct (eq a x); subst; sp.
  right; sp.
Defined.

Lemma subset_diff :
  forall A eq,
  forall l1 l2 l3 : list A,
    subset (diff eq l1 l2) l3
    <=>
    subset l2 (l3 ++ l1).
Proof.
  unfold subset; sp; split; sp.
  apply in_app_iff.
  assert (LIn x l1 + !LIn x l1) by (apply in_deq; auto); sp.
  left; apply_hyp; apply in_diff; sp.
  allrw in_diff; sp.
  apply_in_hyp p.
  allrw in_app_iff; sp.
Qed.

Definition disjoint {T} (l1 l2 : list T) :=
  forall t, LIn t l1 -> !LIn t l2.

Lemma disjoint_nil_r :
  forall T,
  forall l : list T,
    disjoint l [].
Proof.
  unfold disjoint; sp.
Qed.

Hint Immediate disjoint_nil_r.

Lemma disjoint_nil_r_iff :
  forall T,
  forall l : list T,
    disjoint l [] <=> True.
Proof.
  unfold disjoint; sp; split; sp.
Qed.

Hint Rewrite disjoint_nil_r_iff.

Lemma disjoint_nil_l :
  forall T,
  forall l : list T,
    disjoint [] l.
Proof.
  unfold disjoint; sp.
Qed.

Hint Immediate disjoint_nil_l.

Lemma disjoint_nil_l_iff :
  forall T,
  forall l : list T,
    disjoint [] l <=> True.
Proof.
  unfold disjoint; sp; split; sp.
Qed.

Hint Rewrite disjoint_nil_l_iff.

Lemma disjoint_sym_impl :
  forall T,
  forall l1 l2 : list T,
    disjoint l1 l2 -> disjoint l2 l1.
Proof.
  unfold disjoint; sp.
  apply_in_hyp p; sp.
Qed.

Lemma disjoint_sym :
  forall T,
  forall l1 l2 : list T,
    disjoint l1 l2 <=> disjoint l2 l1.
Proof.
  sp; split; sp; apply disjoint_sym_impl; auto.
Qed.

Lemma disjoint_cons_r :
  forall T x,
  forall l1 l2 : list T,
    disjoint l1 (x :: l2)
    <=> disjoint l1 l2 # !LIn x l1.
Proof.
  unfold disjoint; sp; split; sp;
  apply_in_hyp p; allsimpl; sp; subst; sp.
Qed.

Lemma disjoint_cons_l :
  forall T x,
  forall l1 l2 : list T,
    disjoint (x :: l1) l2
    <=> disjoint l1 l2  #  !  LIn x l2.
Proof.
  intros; sp.
  trw disjoint_sym.
  trw disjoint_cons_r.
  trw disjoint_sym; split; auto.
Qed.

Lemma disjoint_iff_diff :
  forall T eq,
  forall l1 l2 : list T,
    disjoint l2 l1 <=> diff eq l1 l2 = l2.
Proof.
  induction l1; simpl; sp.
  trw disjoint_cons_r.
  trw IHl1.

  sp_iff Case; intros; exrepd.

  - Case "->".
  rewrite remove_trivial; auto.

  - Case "<-".
    assert (!LIn a l2)
    by (intro i; rw <- H in i;
        allrw in_diff; sp;
        allrw in_remove; sp).
    rewrite remove_trivial in H; auto.
Qed.

Lemma disjoint_snoc_r :
  forall T,
  forall l1 l2 : list T,
  forall x : T,
    disjoint l1 (snoc l2 x)
    <=> (disjoint l1 l2  #  !  LIn x l1).
Proof.
  unfold disjoint; sp; split; intros.

  - sp; apply_in_hyp p; trw_h in_snoc p; trw_h not_over_or p; sp.
  - sp.
    allrw in_snoc; sp; subst; sp.
    apply_in_hyp p; sp.
Qed.

Lemma disjoint_snoc_l :
  forall T,
  forall l1 l2 : list T,
  forall x : T,
    disjoint (snoc l1 x) l2
    <=> (disjoint l1 l2 # !LIn x l2).
Proof.
  intros; trw disjoint_sym.
  trw disjoint_snoc_r; split; sp; trw disjoint_sym; sp.
Qed.

Lemma subset_disjoint :
  forall T,
  forall l1 l2 l3 : list T,
    subset l1 l2
    -> disjoint l2 l3
    -> disjoint l1 l3.
Proof.
  unfold subset, disjoint; intros; auto.
Qed.

Lemma disjoint_singleton_l :
  forall A (x : A) s,
    disjoint [x] s <=> ! LIn x s.
Proof.
  unfold disjoint; simpl; split; intros; auto; sp; subst; sp.
Qed.

Lemma disjoint_singleton_r :
  forall A (x : A) s,
    disjoint s [x] <=> ! LIn x s.
Proof.
  unfold disjoint; split; simpl; sp; subst; sp.
  apply_in_hyp p; sp.
Qed.

Lemma disjoint_app_l :
  forall A,
  forall l1 l2 l3 : list A,
    disjoint (l1 ++ l2) l3
    <=> (disjoint l1 l3  #  disjoint l2 l3).
Proof.
  induction l1; simpl; sp; split; sp.
  alltrewrite disjoint_cons_l;  trw_h IHl1 H; sp.
  alltrewrite disjoint_cons_l; trw_h IHl1  H; sp.
  alltrewrite disjoint_cons_l; sp.
  trw IHl1; sp.
Qed.

Lemma disjoint_app_r :
  forall A,
  forall l1 l2 l3 : list A,
    disjoint l1 (l2 ++ l3)
    <=> (disjoint l1 l2  #  disjoint l1 l3).
Proof.
  intros; trw disjoint_sym.
  trw disjoint_app_l.
  split; sp; trw disjoint_sym; sp.
Qed.

Lemma disjoint_flat_map_l :
  forall A B,
  forall f : A -> list B,
  forall l1 : list A,
  forall l2 : list B,
    disjoint (flat_map f l1) l2
    <=>
    (forall x,  LIn x l1 -> disjoint (f x) l2).
Proof.
  induction l1; simpl; sp.
  split; sp.
  trw disjoint_app_l.
  trw IHl1.
  split; sp; subst; sp.
Qed.

Lemma disjoint_flat_map_r :
  forall A B,
  forall f : A -> list B,
  forall l1 : list A,
  forall l2 : list B,
    disjoint l2 (flat_map f l1)
    <=>
    (forall x,  LIn x l1 -> disjoint l2 (f x)).
Proof.
  sp.
  rw disjoint_sym.
  rw disjoint_flat_map_l; split; sp;
  rw disjoint_sym; sp.
Qed.

Lemma disjoint_remove_l :
  forall A eq x,
  forall l1 l2 : list A,
    disjoint (remove eq x l1) l2 <=> disjoint l1 (remove eq x l2).
Proof.
  induction l1 as [| ? l IHl1] ; simpl; sp; split; sp.
  trw disjoint_cons_l; sp.
  trw_rev IHl1.
  destruct (eq x a); subst; auto.
  alltrewrite disjoint_cons_l; sp.
  destruct (eq x a); subst; auto.
  alltrewrite in_remove; sp.
  alltrewrite disjoint_cons_l; sp.
  alltrewrite in_remove; sp.
  alltrewrite disjoint_cons_l; sp.
  destruct (eq x a); subst; auto.
  trw IHl1; auto.
  alltrewrite disjoint_cons_l; sp.
  trw IHl1; auto.
  allrw in_remove; sp.
Qed.

Lemma disjoint_diff_l :
  forall A eq,
  forall l1 l2 l3 : list A,
    disjoint (diff eq l1 l2) l3 <=> disjoint l2 (diff eq l1 l3).
Proof.
  induction l1; simpl; sp.
  trw IHl1.
  rewrite diff_remove.
  trw disjoint_remove_l. split; sp.
Qed.

Lemma length0 :
  forall T, forall l : list T,
    length l = 0 <=> l = [].
Proof.
  destruct l; simpl; sp; split; sp; inversion H.
Qed.

Lemma rev_list_indT :
  forall (A : Type) (P : list A -> [univ]),
    P [] ->
    (forall (a : A) (l : list A), P l -> P (snoc l a)) ->
    forall l : list A, P l.
Proof.
  intros.
  assert ({n | length l = n}) as e by (exists (length l); auto); sp.
  revert l e.
  induction n; intros.
  apply length0 in e; subst; sp.
  generalize (snoc_cases A l); sp; subst; auto.
  apph (apply IHn).
  allrewrite length_snoc; allapply S_inj; auto.
Qed.

Lemma rev_list_dest :
  forall T,
  forall l : list T,
    l = [] [+] {u : list T $ {v : T $ l = snoc u v}}.
Proof.
  induction l using rev_list_indT.
  left; auto.
  right; auto.
  exists l a; auto.
Qed.

Lemma rev_list_dest2 :
  forall {T} (l : list T),
    l = [] [+] {u : list T $ {v : T $ l = snoc u v}}.
Proof.
  induction l using rev_list_indT.
  left; auto.
  right; auto.
  exists l a; auto.
Qed.

Ltac rev_list_dest l :=
  let name := fresh "or" in
  generalize (rev_list_dest2 l);
    intro name;
    destruct name;
    try exrepd;
    subst.

Lemma rev_list_ind :
  forall (A : Type) (P : list A -> Prop),
    P [] ->
    (forall (a : A) (l : list A), P l -> P (snoc l a)) ->
    forall l : list A, P l.
Proof.
  intros.
  assert ({n : nat $ length l = n}) as p by (exists (length l); auto).
  destruct p as [n e].
  revert l e.
  induction n; intros.
  apply length0 in e; subst; sp.
  generalize (snoc_cases A l); sp; subst; auto.
  apply H0.
  apply IHn.
  allrewrite length_snoc; allapply S_inj; auto.
Qed.

Lemma combine_in_left : forall T1 T2 (l1: list T1) (l2: list T2),
 (length l1=length l2) -> forall u1, ( LIn u1 l1)  -> {u2 : T2 $ LIn (u1,u2) (combine l1 l2)}.
Proof. induction l1; intros ? Hlen ?   Hin; inverts Hin as Hin; simpl in Hlen;
  destruct l2 ; simpl in Hlen; inversion Hlen.
 -  subst.  exists t. simpl. left; auto.
 - apply IHl1 with l2 u1 in Hin; auto. parallel u2 Hcom.
   simpl. right; auto.
Qed.

Lemma combine_in_left2 : forall T1 T2 (l1: list T1) (l2: list T2),
 (length l1 <= length l2) -> forall u1, ( LIn u1 l1)  -> {u2 : T2 $ LIn (u1,u2) (combine l1 l2)}.
Proof. induction l1; intros ? Hlen ?   Hin. inverts Hin as Hin; simpl in Hlen.
  destruct l2 ; simpl in Hlen. omega. inverts Hin as Hin.
 -  subst.  exists t. simpl. left; auto.
 - apply IHl1 with l2 u1 in Hin; auto. parallel u2 Hcom.
   simpl. right; auto. omega.
Qed.

Lemma cons_as_app :
  forall T (a : T) (b : list T),
    a :: b = [a] ++ b.
Proof. sp. Qed.

Lemma length1 :
  forall T, forall l : list T,
    length l = 1 <=> {x : T $ l = [x]}.
Proof.
  destruct l; simpl; sp.
  split; sp; inversion H.
  split; sp; try (inversion H); subst.
  destruct l; simpl in H1; inversion H1.
  exists t; auto.
  invs; sp.
Qed.

Lemma snoc1 :
  forall T,
  forall a : list T,
  forall b x : T,
    snoc a b = [x] <=> a = []  #  b = x.
Proof.
  destruct a; simpl; sp; split; sp; subst; auto.
  inversion H; auto.
  inversion H; subst; auto.
  destruct a; simpl in H2; inversion H2.
  inversion H; subst; auto.
  destruct a; simpl in H2; inversion H2.
Qed.


Theorem in_single: forall T (a b : T),  LIn a [b] -> a=b.
Proof. introv H. invertsn H. auto. inversion H.
Qed.


Lemma in_list2 : forall T (x a b :T),
 ( LIn x [a,b]) -> (x=a [+]  x=b).
Proof. introv H. invertsn H. left; auto.
       invertsn H;  right; auto.
       inverts H.
Qed.

Tactic Notation "dlist2"  ident(h) :=
 apply in_list2 in h; destruct h.

Lemma in_list2_elim : forall T ( a b :T) (P: T-> Prop),
 (forall x, ( LIn x [a,b]) -> P x) -> (P a  #   P b).
Proof. introv H. split; apply H; simpl; auto.
Qed.

Lemma in_list1 :
  forall T (x a :T),
     LIn x [a] -> x = a.
Proof.
  introv H. invertsn H. auto.
  inverts H.
Qed.

Lemma in_list1_elim : forall T (x a b :T) (P: T-> Prop),
 (forall x, ( LIn x [a]) -> P x) -> (P a).
Proof. intros. apply H; simpl; auto.
Qed.

Tactic Notation "dlist" ident(l) ident(cs) "as" simple_intropattern(I) :=
 destruct l as I;
  [ Case_aux cs "nilcase"
  | Case_aux cs "conscase"
  ].

Lemma app_split :
  forall T,
  forall l1 l2 l3 l4 : list T,
    length l1 = length l3
    -> l1 ++ l2 = l3 ++ l4
    -> l1 = l3  #  l2 = l4.
Proof.
  induction l1; simpl; sp.
  destruct l3; allsimpl; auto.
  inversion H.
  destruct l3; allsimpl; auto.
  inversion H.
  destruct l3; allsimpl; auto.
  inversion H.
  inversion H0; subst.
  apply IHl1 in H3; sp; subst; auto.
  inversion H0; subst.
  destruct l3; allsimpl; auto.
  inversion H.
  inversion H0; subst.
  apply IHl1 in H4; sp; subst; auto.
Qed.
Lemma cons_eq :
  forall A a,
  forall b c : list A,
    b = c -> a :: b = a :: c.
Proof.
  sp; subst; sp.
Qed.

Lemma cons_app :
  forall T (x : T) l1 l2,
    x :: (l1 ++ l2) = (x :: l1) ++ l2.
Proof.
  sp.
Qed.

Lemma cons_snoc :
  forall T (x y : T) l,
    x :: (snoc l y) = snoc (x :: l) y.
Proof.
  sp.
Qed.

Fixpoint repeat {T} (n:nat) (t:T):=
 match n with
 | O => []
 | S m => t::(repeat m t)
 end.

Lemma cons_inj :
  forall A (a c : A) b d,
    a :: b = c :: d -> a = c  #  b = d.
Proof.
  sp; inversion H; sp.
Qed.

Lemma in_combine :
  forall A B a b,
  forall l1 : list A,
  forall l2 : list B,
     LIn (a,b) (combine l1 l2)
    ->  LIn a l1  #   LIn b l2.
Proof.
  induction l1; introv Hlin; simpl; sp; destruct l2; allsimpl; sp;
    allapply pair_inj; repnd; subst; sp; apply_in_hyp p; sp.
Qed.

Lemma implies_in_combine :
  forall A B (l1 : list A) (l2 : list B) x,
    length l1 = length l2
    ->  LIn x l1
    -> {y : B $ LIn (x, y) (combine l1 l2)}.
Proof.
  induction l1; simpl; sp; destruct l2; allsimpl; subst; sp;
  invertsn H.
  exists b; sp.
  apply IHl1  with(x:=x) in H; sp.
  exists y; sp.
Qed.

Lemma repeat_length : forall T n (t:T), length(repeat n t)=n.
Proof.
  induction n; intros; simpl; try omega. rewrite IHn. auto.
Qed.

Lemma in_repeat : forall T n (u t:T),  LIn u (repeat n t) -> u=t.
Proof. induction n; introv H; simpl. inverts H.
 simpl in H. destruct H; auto.
Qed.

Lemma combine_app_eq: forall A B (l1:list A) (l21 l22: list B),
 length l1 <= length l21 -> combine l1 l21 = combine l1 (l21 ++ l22).
Proof. induction l1;
 intros ? ? Hle; simpl; auto.
 destruct l21; simpl. inverts Hle.
 rewrite <- IHl1; allsimpl; try omega; auto.
Qed.

Lemma combine_nil :
  forall A B (l : list A),
    combine l (@nil B) = nil.
Proof.
  induction l; simpl; auto.
Qed.

Hint Rewrite combine_nil.

Lemma firstn_nil:
  forall n T , firstn n nil = @nil T.
Proof.
  induction n; intros; simpl; auto.
Qed.

Hint Rewrite firstn_nil.

Lemma app_eq_nil_iff :
  forall T (l1 l2 : list T),
    l1 ++ l2 = [] <=> (l1 = []  #  l2 = []).
Proof.
  sp; split; sp; subst; sp; destruct l1; destruct l2; allsimpl; sp.
Qed.

Lemma combine_app_app :
  forall A B (l1:list A) (l21 l22: list B),
    length l21 <= length l1
    -> combine l1 (l21 ++ l22) =
       combine l1 l21
               ++
               combine (skipn (length l21) l1) (firstn  (length l1-length l21) l22).
Proof.
  induction l1; intros ? ? Hle. inverts Hle. trw_h length0  H0. subst.
  simpl. auto.
  simpl. destruct l21; destruct l22; simpl; auto; try omega.
  - fold (app nil l22). rewrite IHl1. rewrite combine_nil. simpl.
    assert (length l1 - 0 =length l1) as Hmin by omega. rewrite Hmin. auto.
    simpl. omega.
  - rewrite app_nil_r. rewrite firstn_nil. rewrite combine_nil. rewrite app_nil_r. auto.
  - simpl in Hle. simpl. rewrite  IHl1; auto; omega.
Qed.

Lemma in_firstn : forall T n a (l: list T),
 n>0 ->  LIn a (firstn n l) ->  LIn a l.
Proof. induction n;  intros ? ? Hgt Hin.
 inverts Hin. destruct l. inverts Hin.
 simpl in Hin. dorn Hin. left; auto.
 right; auto. destruct n. inverts Hin. apply IHn; auto. omega.
Qed.

(* Counter-example: al = [0;1], a = 1, n = 1, t = 0, then ( LIn 1 al) is true
 * but  LIn (1,0) (combine al (repeat n t)) is  LIn (1,0) [(0,0)] is false.
 * It is true if length al = n though. *)
Lemma false_in_combine_repeat :
  forall A B (al : list A) (t : B) n,
    n > 0
    -> forall a,  LIn a al ->  LIn (a,t) (combine al (repeat n t)).
Abort.

Lemma in_combine_repeat :
  forall A B (al : list A) (t : B) n,
    length al <= n
    -> forall a,  LIn a al ->  LIn (a,t) (combine al (repeat n t)).
Proof.
  induction al; simpl; sp; subst; destruct n; try omega;
  allapply S_le_inj; simpl; sp.
Qed.

Lemma length_filter :
  forall T f (l : list T),
    length (filter f l) <= length l.
Proof.
  induction l; simpl; sp.
  destruct (f a); simpl; omega.
Qed.

Lemma filter_snoc :
  forall T f (l : list T) x,
    filter f (snoc l x)
    = if f x then snoc (filter f l) x else filter f l.
Proof.
  induction l; simpl; sp.
  destruct (f a); simpl; rewrite IHl; destruct (f x); sp.
Qed.

Theorem eq_list
     : forall (A : Type) (x : A) (l1 l2 : list A),
       l1 = l2 <=>
       length l1 = length l2  #  (forall n : nat, nth n l1 x = nth n l2 x).
Proof.
  intros. apply eq_lists.
Qed.

Theorem nat_compare_dec: forall m n, (n < m [+]  m <= n ).
Proof. induction m. destruct n. right. auto. 
    right. omega. intros.  destruct (IHm n); 
    destruct (eq_nat_dec n m); subst;
    try( left; omega);    
    try( right; omega).    
Qed. 

Theorem eq_list2
     : forall (A : Type) (x : A) (l1 l2 : list A),
       l1 = l2 <=>
       length l1 = length l2  #  (forall n : nat, n<length l1 -> nth n l1 x = nth n l2 x).
Proof.
  intros. split ; introv H. 
  eapply eq_list  in H. repnd. split; auto.
  repnd. eapply  eq_list; split; eauto.
  intros. assert (n < length l1 \/  length l1 <= n ) as Hdic by omega.
  destruct Hdic. apply H; auto. repeat (rewrite nth_overflow ); auto.
  rewrite <- H0; auto.
Qed.

Lemma singleton_as_snoc :
  forall T (x : T),
    [x] = snoc [] x.
Proof.
  sp.
Qed.

Theorem map_eq_length_eq :
  forall A B (f g : A -> B) la1 la2,
    map f la1 = map g la2
    -> length la1 = length la2.
Proof.
   introv Hmap. apply (apply_eq (@length B)) in Hmap.
   repeat (rewrite map_length in Hmap); trivial.
Qed.

Theorem  nth2 : forall {A:Type} (l:list A) (n:nat) (ev: n < length l) , A .
Proof. induction l; simpl. intros. provefalse.
 inversion ev.
  intros.
  destruct (eq_nat_dec n 0). subst.
  exact a.
  apply IHl with (n:=(n-1)).
  destruct n. destruct n0. reflexivity.
  omega.
Qed.

Theorem  nth3 : forall {A:Type} (l:list A) (n:nat) (ev: n < length l) , {x:A | nth n l x =x} .
Proof. induction l; simpl. intros. provefalse.
 inversion ev.
  intros.
  destruct n . subst.
  exact (exist (eq a) a eq_refl ).
  apply IHl with (n:=(n)).
  omega.
Qed.


Definition eq_set {A} (l1 l2: list A) := subset l1 l2  #  subset l2 l1.
Definition eq_set2 {A} (l1 l2: list A) := forall a ,  LIn a l1 <=>  LIn a l2.

Theorem eq_set_iff_eq_set2 :
  forall {A} (l1 l2: list A),
    eq_set l1 l2 <=> eq_set2 l1 l2.
Proof.
  unfold eq_set, eq_set2, subset.
  repeat(split;sp); apply_hyp; auto.
Qed.

Theorem eq_set_refl : forall {A} (l: list A) , eq_set l l.
Proof. split; apply subset_refl.
Qed.

Theorem eq_set_refl2: forall (A : Type) (l1 l2 : list A), (l1=l2) -> eq_set l1 l2.
Proof. intros. rewrite H. apply eq_set_refl.
Qed.

Theorem eq_set_empty :
  forall {A} (l1 l2: list A),
    eq_set l1 l2
    -> l1 = []
    -> l2 = [].
Proof.
  introv Heqs Heql. apply null_iff_nil. introv v. apply eq_set_iff_eq_set2 in Heqs.
  apply Heqs in v. subst. inverts v.
Qed.

Theorem nth2_equiv :
  forall (A:Type) (l:list A) (n:nat) (def:A)
         (ev: n < length l),
    (nth n l def) = nth2 l n ev.
Abort.

Theorem len_flat_map: forall {A B} (f:A->list B)  (l: list A),
    length (flat_map f l) = addl (map (fun x => length (f x)) l) .
Proof. induction l; auto. simpl. rewrite length_app. f_equal. auto.
Qed.

(** renaming due to some name clash
Lemma rev_list_ind2 :
  forall (A : Type) (P : list A -> Prop),
    P [] ->
    (forall (a : A) (l : list A), P l -> P (snoc l a)) ->
    forall l : list A, P l.
Proof.
  intros.
  assert (texists n, length l = n) by (exists(length l); auto); sp.
  revert l H1.
  induction n; intros.
  destruct l; simpl in H1; auto; inversion H1.
  assert (l = [] [+] exists(a : A), exists(k : list A), l = snoc k a) by apply snoc_cases.
  sp; subst; auto.
  apply H0.
  apply IHn.
  rewrite length_snoc in H1; inversion H1; auto.
Qed.
*)

(** asserts that a list has no repeated elements. need not have decidable equality *)
Inductive no_repeats {T} : list T -> [univ] :=
  | no_rep_nil : no_repeats []
  | no_rep_cons :
      forall x xs,
        !LIn x xs
        -> no_repeats xs
        -> no_repeats (x :: xs).


Theorem last_snoc: forall A (l:list A) (a d:A) ,
  nth (length l) (snoc l a) d= a.
Proof. 
    induction l ; introv . refl. 
    rewrite snoc_as_append. rewrite app_nth2. 
    simpl. asserts_rewrite (length l - length l=0); try omega. 
    auto. omega. 
Qed. 

Theorem eq_maps2:
  forall (A B C: Type) (f : A -> B) (g  : C -> B) (la : list A) (lc : list C) defa defc,
  length la = length lc
  -> (forall n ,  n < length la -> f  (nth n la defa) = g ( nth  n lc defc)) 
  -> map f la = map g lc.
Proof. induction la using rev_list_ind; introv Hleq Hp. 
  invertsn Hleq. symmetry in Hleq. rw length0 in Hleq. subst. 
  reflexivity. allrewrite snoc_as_append. rewrite map_app. 
  rewrite length_app in Hleq. allsimpl. rev_list_dest lc. invertsn Hleq. 
  omega. allrewrite snoc_as_append. rewrite map_app. allsimpl. 
  rewrite length_app in Hleq. allsimpl. 
  assert (length la = length u) as Hleq1 by omega.
  f_equal. eapply IHla; eauto. 
  intros. assert (n < length (la++[a])) as Hla. rewrite length_app. 
  omega. apply Hp in Hla. 
  rewrite app_nth1 in Hla; auto.  rewrite app_nth1 in Hla; auto.
  eauto. rewrite <- Hleq1; auto. 
  instlemma (Hp (length la)) as Hle.
  rewrite <- snoc_as_append in Hle. 
  rewrite <- snoc_as_append in Hle. 
  rewrite last_snoc in Hle. 
  rewrite Hleq1 in Hle. 
  rewrite last_snoc in Hle. 
  f_equal; auto. apply Hle. 
  rewrite <- Hleq1. 
  rewrite length_snoc; omega. 
Qed.


(**generalized map where the mapping function takes
  evidence of elements being in the list *)
Lemma gmap:  forall {A B : Type} (l: list A) (f : forall a, LIn a l -> B),
    list B.
Proof. induction l as [| a  l maprec]; introv f. exact nil.
   pose proof f a as Hb. lapply Hb;[ intro b | left; auto].
   assert ( forall a0 : A, LIn a0 (l) -> B) as frec. introv Hin.
   eapply f. right. eauto.
   pose proof (maprec frec) as brec.
   exact (b::brec).
Defined.

Lemma map_gmap_eq : forall {A B : Type} (l: list A) 
  (f : forall a, LIn a l -> B) (g: A->B),
  (forall a (p: LIn a l), f a p = g a)
   -> map g l = gmap l f. 
Proof. induction l as [| a l Hind]; introv Heq;[reflexivity | ]. 
  simpl. f_equal. rewrite Heq. reflexivity. 
  apply Hind. intros. rewrite Heq; reflexivity. 
Qed.

Fixpoint appl {A: Type} (l: list (list A)) : list A :=
 match l with
 | [] => []
 | h::t => h ++ appl t
 end.

Theorem flat_map_as_appl_map:
 forall {A B:Type} (f: A->list B) (l : list A),
   flat_map f l = appl (map f l).
Proof.
 induction l; auto. 
 simpl. rw IHl; auto. 
Qed.

Lemma gmap_length : forall (A B : Type) (l : list A)
  (f:(forall a : A, LIn a l -> B)),
    length (gmap l f)= length l.
Proof.
  induction l; auto.
  intros. simpl. f_equal.
  rewrite IHl; auto.
Qed.

Lemma map_eq_injective:  forall {A B: Type} (f: A->B) (pinj: injective_fun f)
  (lvi lvo: list A),
  map f lvi = map f lvo -> lvi = lvo.
Proof.
  induction lvi as [| vi lvi Hind]; introv Hm; destruct lvo; (try invertsn Hm); auto.
  apply pinj in Hm. f_equal; auto.
Qed.

Tactic Notation "cases_if_sum"  simple_intropattern(newname) :=
  cases_if; clears_last;
   let H:= get_last_hyp tt in rename H into newname.

Lemma map_remove_commute: forall {A B : Type} (eqa : Deq A)
(eqb : Deq B) (f: A->B) (r: A) (lvi: list A) (fi : injective_fun f),
  map f (remove eqa r lvi)
  = remove eqb (f r) (map f lvi).
Proof.
  intros. induction lvi; auto.
 simpl. symmetry. cases_if as Ha; cases_if as Hb; subst; sp.
 - apply fi in Ha. subst; sp.
 - simpl. f_equal; auto.
Qed.

Lemma map_diff_commute: forall {A B : Type} (eqa : Deq A)
(eqb : Deq B) (f: A->B) (lvr lvi: list A) (fi : injective_fun f),
  map f (diff eqa lvr lvi)
  = diff eqb (map f lvr) (map f lvi).
Proof.
  induction lvr as [| ? lvr IHlvr]; intros; try(repeat (rewrite diff_nil)); auto;[].
  simpl. rewrite IHlvr; auto.  f_equal; auto.
  apply map_remove_commute; auto.
Qed.

Lemma memberb_din :
  forall (S T : Type)
         (deq : Deq S)
         (v : S)
         (lv : list S)
         (ct cf : T),
    (if memberb deq v lv then ct else cf)
    = (if in_deq _ deq v lv then ct else cf).
Proof.
  intros. cases_if  as Hb; auto; cases_if_sum Hd ; auto; subst.
  apply assert_memberb in Hb. sp.
  rw <- (@assert_memberb S deq) in Hd.
  rewrite Hd in Hb.
  sp.
Qed.

Theorem fst_split_as_map: forall {A B :Type} (sub : list (A * B)),
    fst (split sub) = map (fun p=> fst p) sub.
Proof.
  intros. induction sub as [| vt sub Hind]; auto.
  simpl. destruct vt as [v t].
  simpl. destruct (split sub). allsimpl.
  f_equal. auto.
Qed.

Theorem snd_split_as_map: forall {A B :Type} (sub : list (A * B)),
    snd (split sub) = map (fun p=> snd p) sub.
Proof.
  intros. induction sub as [| vt sub Hind]; auto.
  simpl. destruct vt as [v t].
  simpl. destruct (split sub). allsimpl.
  f_equal. auto.
Qed.

Lemma combine_in_right : forall T1 T2 (l2: list T2) (l1: list T1),
 (length l2 <= length l1) 
  -> forall u2, ( LIn u2 l2) 
  -> {u1 : T1 $ LIn (u1,u2) (combine l1 l2)}.
Proof. induction l2; intros ? Hlen ?   Hin. inverts Hin as Hin; 
  simpl in Hlen.
  destruct l1 ; simpl in Hlen. omega. inverts Hin as Hin.
 -  subst.  exists t. simpl. left; auto.
 - apply IHl2 with l1 u2 in Hin; auto. parallel u Hcom.
   simpl. right; auto. omega.
Qed.

(** just like nth, but no need to provide a default element *)
Fixpoint select {A:Type} (n:nat) (l:list A): option A :=
   match n with
  | 0 => match l with
         | [] => None
         | x :: _ => Some x
         end
  | S m => match l with
           | [] => None
           | _ :: t => select m t 
           end
  end.

Lemma nth_select1: forall {A:Type} (n:nat) (l:list A)  (def: A),
  n < length l -> select  n l= Some (nth n l def).
Proof.
  induction n as [|n Hind]; introv Hl; destruct l;try (inverts Hl;fail); simpl; auto.
  allsimpl. erewrite Hind; eauto. omega.
Qed.

Lemma nth_select2: forall {A:Type} (n:nat) (l:list A) ,
  n >= length l <=> select  n l= None.
Proof.
  induction n as [|n Hind];  destruct l; allsimpl; try (split;sp;omega;fail).
  split;intro H.
  apply Hind; auto. omega.
  apply Hind in H; auto. omega. 
Qed.
  
Lemma first_index {A: Type} (l: list A) (a:A) (deq : Deq A): 
  {n:nat $ n < length l # nth n l a= a #(forall m, m<n -> nth m l a <>a)}
     [+] (! (LIn a l)).
Proof.
  induction l as [| h l Hind]; [right;sp;fail|].
  destruct (deq h a); subst; allsimpl;[left ; exists 0; sp; omega | ].
  dorn Hind. 
  + exrepnd. left. exists (S n0). split; auto; try omega; split; auto.
     introv Hlt. destruct m; auto. apply Hind0; omega.
  + right. intro Hc; sp.
Defined.

Lemma split_length_eq: forall {A B :Type} (sub : list (A * B)),
  let (la,lb):= split sub in
    length la=length lb # length la= length sub.
Proof.
  intros. destructr (split sub) as [la lb].
  assert(la=fst (la,lb)) as h99 by (simpl;auto).
  rewrite h99. rewrite HeqHdeq. rewrite split_length_l. clear h99.
  assert(lb=snd (la,lb)) as h99 by (simpl;auto).
  rewrite h99. rewrite HeqHdeq. rewrite split_length_r.
  sp.
Qed.


Ltac disjoint_reasoning :=
match goal with
| [  |- disjoint _ (_ ++ _) ] => apply disjoint_app_r;split
| [  |- disjoint (_ ++ _) _ ] => apply disjoint_app_l;split
| [  |- disjoint _ (_ :: _) ] => apply disjoint_cons_r;split
| [  |- disjoint (_ :: _) _ ] => apply disjoint_cons_l;split
| [  |- disjoint _ _ ] => (sp;fail  || apply disjoint_sym; sp;fail)
(** important to leave it the way it was .. so that repeat progress won't loop*)
| [ H: disjoint _ (_ ++ _) |- _ ] => apply disjoint_app_r in H;sp
| [ H: disjoint (_ ++ _) _ |- _ ] => apply disjoint_app_l in H;sp
| [ H: disjoint _ (_ :: _) |- _ ] => apply disjoint_cons_r in H;sp
| [ H: disjoint (_ :: _) _ |- _ ] => apply disjoint_cons_l in H;sp
| [ H: !(disjoint  _ []) |- _ ] => provefalse; apply H; apply disjoint_nil_r
| [ H: !(disjoint  [] _) |- _ ] => provefalse; apply H; apply disjoint_nil_l
| [ H: (disjoint  _ []) |- _ ] => clear H
| [ H: (disjoint  [] _) |- _ ] => clear H
end.


Lemma select_lt : forall {A:Type} (l: list A) (a:A) n,
  select n l = Some a -> n < length l.
Proof.
  introv Heq. 
  assert (n<length l \/ n>=length l ) as XX by omega.
  dorn XX; auto. apply nth_select2 in XX. rewrite XX in Heq.
  inverts Heq.
Qed.

Lemma select_in : forall {A:Type} (l: list A) (a:A) n,
  select n l = Some a -> LIn a l.
Proof.
  introv Heq. duplicate Heq. apply select_lt in Heq.
  pose proof (nth_select1 _ _ a Heq) as XX.
  rewrite XX in Heq0. invertsn Heq0.
  pose proof (nth_in _ _ l a Heq) as XXX.
  auto.
Qed.

Lemma no_repeats_index_unique: forall {T:Type} 
  (a:T) (n1 n2:nat) (l:list T),
  no_repeats l
  -> select n1 l = Some a
  -> select n2 l = Some a
  -> n1 = n2.
Proof.
  induction n1 as [| n1 Hind]; introv Hnr H1s H2s; auto; destruct l as [| h l].

  inverts H1s.

  allsimpl. inverts Hnr. destruct n2; auto.
  allsimpl. invertsn H1s.
  apply select_in in H2s. sp.

  destruct n2; inverts H2s.

  allsimpl. destruct n2.
  inverts H2s. inverts Hnr. apply select_in in H1s. sp.
  f_equal. allsimpl. 
  apply Hind with (l:=l); eauto.
  inverts Hnr; auto.
Qed.
  
Lemma nth_select3:
  forall (A : Type) (n : nat) (l : list A) (a def : A),
  n < length l
  -> (nth n l def) =a
  ->  select n l = Some a.
Proof.
  introv K1 K2.
  pose proof (nth_select1  n l def K1).
  congruence.
Qed.


Lemma no_repeats_index_unique2: forall {T:Type} (l:list T)
  (a:T) (n1 n2:nat) (def1 def2: T),
  no_repeats l
  ->  n1 < length l
  ->  n2 < length l
  -> (nth n1 l def1 =a)
  -> (nth n2 l def2 =a)
  -> n1 = n2.
Proof.
  introv K1 K2 K3 K4 K5.
  apply nth_select3 in K4; auto.
  apply nth_select3 in K5; auto.
  pose proof (no_repeats_index_unique _ _ _ _ K1 K4 K5). trivial.
Qed.


Lemma length_combine_eq : forall {A B: Type} (la:list A) (lb: list B), 
  length la =length lb
  -> length (combine la lb) = length la.
Proof.
  introv XX. rewrite combine_length.
  rewrite XX. apply Min.min_idempotent.
Qed.

Lemma nth_in2:
  forall (A : Type) (n : nat) (l : list A) (a d : A),
  n < length l -> (nth n l d) = a -> LIn a l.
Proof.
  introns XX. pose proof (nth_in _ n l d XX) as XY. congruence.
Qed.

Definition not_in_prefix {A: Type} (la : list A) (a:A) (n:nat) :=
               (forall m : nat,
                     m < n -> nth m la a <> a).

  
 Definition lforall {A:Type} (P: A-> Type) (l:list A) :=
  forall a:A, LIn a l -> P a.

Lemma implies_lforall : forall {A:Type} (P Q: A->Type),
  (forall (a b :A), P a -> Q a)
   -> forall l,  lforall P l-> lforall Q l.
Proof.
  unfold lforall. sp.
Defined.

Lemma combine_eq : forall {A B: Type} 
  (l1a l2a: list A) (l1b l2b: list B),
  combine l1a l1b = combine l2a l2b
  -> length l1a = length l1b
  -> length l2a = length l2b
  -> l1a=l2a # l1b=l2b.
Proof.
  induction l1a as [|a1 l1a Hind]; auto; introv Hc He1 He2;
  allsimpl; destruct l1b; destruct l2b; destruct l2a;  
   try(invertsn He1); try(invertsn He2); allsimpl; try(invertsn Hc); auto.
  pose proof (Hind _ _ _ Hc He1 He2) as Xr. repnd.
  rewrite Xr. rewrite Xr0; split; sp.
Qed.

Definition binrel_list {T}
           (def : T)
           (R : @bin_rel T)
           (tls trs : list T) : [univ] :=
  length tls = length trs
  # (forall (n : nat),
       n < length tls
       -> R (nth n tls def) (nth n trs def)).

Lemma length2 :
  forall (T : Type) (l : list T),
    length l = 2 -> {x, y : T $ l = [x,y]}.
Proof.
  introv Hl. destruct l; try(destruct l); try(destruct l); inverts Hl.
  eexists; eauto.
Qed.

Lemma length3 :
  forall (T : Type) (l : list T),
    length l = 3 -> {x, y, z : T $ l = [x,y,z]}.
Proof.
  introv Hl. destruct l; try(destruct l); try(destruct l);  try(destruct l); inverts Hl.
  repeat(eexists); eauto.
Qed.

Lemma length4 :
  forall (T : Type) (l : list T),
    length l = 4 -> {x, y, z , u : T $ l = [x,y,z,u]}.
Proof.
  introv Hl. destruct l; try(destruct l); try(destruct l);
      try(destruct l);  try(destruct l);  inverts Hl.
  repeat(eexists); eauto.
Qed.

Definition is_first_index {T:Type} (l: list T) (t:T) (n:nat) :=
  n< length l # nth n l t = t # not_in_prefix l t n.
 
Lemma is_first_index_unique : forall {T:Type} (l: list T) (t:T) (n1 n2 :nat),
  is_first_index l t n1
  -> is_first_index l t n2
  -> n1 = n2.
Proof.
  unfold is_first_index, not_in_prefix. introv s1s s3s.
  repnd.
  assert (n1<n2 \/ n1=n2 \/ n2<n1) as Htri by omega.
  (dorn Htri);[|(dorn Htri)]; sp;
  try (apply s1s in Htri); sp;
  try (apply s3s in Htri); sp.
Qed.

Lemma disjoint_app_lr : forall {A:Type} (l1 l2 r1 r2 : list A),
  disjoint (l1 ++ l2) (r1 ++ r2)
    <=>
  (disjoint l1 r1 # disjoint l1 r2) # disjoint l2 r1 # disjoint l2 r2.
Proof.
   introv. rw disjoint_app_l. rw disjoint_app_r.
    rw disjoint_app_r. apply t_iff_refl.
Qed.

Lemma dec_disjoint :
  forall {T:Type} (deqt: Deq T) (la lb: list T),
    disjoint la lb + (!disjoint la lb).
Proof.
  induction la as [|a la IHla]; sp.
  simpl. destruct (IHla lb) as [dd|nd];[|right].
  - destruct (in_deq T deqt a lb);[right|left];sp;disjoint_reasoning;sp.
  - sp. apply nd. disjoint_reasoning; sp.
Defined.

Ltac simpl_list :=
  match goal with
    | [ H : context[length (map _ _)] |- _] => rewrite map_length in H
    | [ |-  context[length (map _ _)] ] => rewrite map_length
    | [ H : LIn ?x [?h] |- _ ] => apply in_single in H; subst
  end.

Lemma bin_rel_list_refl :
  forall {T} (R: bin_rel T) (def:T),
    refl_rel R -> refl_rel (binrel_list def R).
Proof.
  introv HR. intro l. split; sp.
Qed.

Lemma pairInProofsCons :
  forall {A:Type} (l: list A) (h:A),
    {a: A $ LIn a l}
    -> {a: A $ LIn a (h::l)}.
Proof.
  introv ph. exrepnd.
  exists a.
  right. trivial.
Defined.

Lemma pairInProofs: forall {A:Type} (l: list A) , list {a: A $ LIn a l}.
Proof.
  induction l as [| a l Hind];[exact []|].
  pose proof (map (pairInProofsCons l a) Hind) as Hind'.
  exact (exI(a,injL(eq_refl a))::Hind').
Defined.

Theorem in_single_iff: forall T (a b : T),  LIn a [b] <=> a=b.
Proof. split.
  - introv H. invertsn H. auto. inversion H.
  - introv H. constructor. sp.
Qed.

Lemma lin_lift: forall {A B:Type} (a:A) (lv: list A) (f:A->B),
  LIn a lv ->  LIn (f a) (map f lv).
Proof.
  induction lv as [| v lv Hind] ; [sp | ]; introv Hin. simpl.
  dorn Hin;subst;spc.
Qed.

Lemma flat_map_app:
  forall (A B : Type) (f : A -> list B) (l l' : list A),
  flat_map f (l ++ l') = flat_map f l ++ flat_map f l'.
Proof.
  induction l as [| a l Hind]; introv;sp.
  simpl. rw <- app_assoc.
  f_equal. sp.
Qed.

Lemma deq_list {A} (deq : Deq A): Deq (list A).
Proof.
  intro lx.
  induction lx as [| x lx Hind]; intro ly;
  destruct ly as [| y ly];sp;[right|right |];sp;[].
  destruct (Hind ly); destruct (deq x y); subst; sp; right; introv Heq;
  inverts Heq; sp.
Qed.
Hint Resolve deq_list.

Ltac get_element_type listtype :=
match listtype with
list ?T => T
end.

Ltac apply_length  H :=
  match goal with
      [ H: (?l = ?r) |- _ ] =>
      let T:= (type of l) in
      let Tin := get_element_type T in
      let Hn := fresh H "len" in
      apply_eq (@length Tin) H Hn; try (rw map_length in Hn)
  end.

Lemma filter_app :
  forall T f (l1 l2 : list T),
    filter f (l1 ++ l2) = filter f l1 ++ filter f l2.
Proof.
  induction l1; simpl; sp.
  rw IHl1.
  destruct (f a); sp.
Qed.

Lemma subset_singleton_r :
  forall T (l : list T) x,
    subset l [x] <=> forall y, LIn y l -> y = x.
Proof.
  unfold subset; introv; simpl; split; sp; apply_in_hyp p; sp.
Qed.

Lemma split_eta :
  forall A B (l : list (A * B)),
    split l = (fst (split l), snd (split l)).
Proof.
  induction l; simpl; sp.
  rw IHl; simpl; sp.
Qed.

Lemma split_cons :
  forall A B a b (l : list (A * B)),
    split ((a, b) :: l) = (a :: fst (split l), b :: (snd (split l))).
Proof.
  simpl; sp.
  rw split_eta; simpl; sp.
Qed.

Lemma simpl_fst :
  forall A B (a : A) (b : B), fst (a, b) = a.
Proof. sp. Qed.

Fixpoint gmapd {A B : Type} (l : list A) : (forall a, LIn a l -> B) -> list B :=
  match l with
    | [] => fun f => []
    | x :: xs =>
      fun (f : forall a, LIn a (x::xs) -> B) =>
        (f x (injL(eq_refl))) :: gmapd xs (fun a i => f a (injR(i)))
  end.

Lemma gmap_eq_d :
  forall A B (l : list A) (f : forall a : A, LIn a l -> B),
    gmap l f = gmapd l f.
Proof.
  induction l; simpl; sp.
  rw IHl; sp.
Qed.

Lemma eq_gmaps :
  forall A B,
  forall l : list A,
  forall f g : (forall a : A, LIn a l -> B),
    (forall a (i : LIn a l), f a i = g a i)
    -> gmap l f = gmap l g.
Proof.
  induction l; simpl; sp.
  generalize (H a (injL(eq_refl))); intro e.
  rewrite e.
  apply cons_eq; sp.
Qed.

Lemma eq_gmapds :
  forall A B,
  forall l : list A,
  forall f g : (forall a : A, LIn a l -> B),
    (forall a (i : LIn a l), f a i = g a i)
    -> gmapd l f = gmapd l g.
Proof.
  intros.
  repeat (rw <- gmap_eq_d).
  apply eq_gmaps; sp.
Qed.

Lemma combine_cons :
  forall A B (x : A) (y : B) l k,
    combine (x :: l) (y :: k) = (x, y) :: combine l k.
Proof. sp. Qed.

Lemma map_cons :
  forall A B (x : A) (f : A -> B) l,
    map f (x :: l) = (f x) :: map f l.
Proof. sp. Qed.

Lemma Lin_eauto1 : forall {T:Type} (a:T) (l: list T),
  LIn a (a::l).
Proof.
  intros. simpl. left; sp.
Qed.

Lemma Lin_eauto2 : forall {T:Type} (a b:T) (l: list T),
  LIn b l -> LIn b (a::l).
Proof.
  intros. simpl. right; sp.
Qed.

Hint Resolve Lin_eauto1 Lin_eauto2 : slow.

Ltac disjoint_lin_contra :=
    match goal with 
    [ H1 : LIn ?t ?lv1 , H2 : LIn ?t ?lv2, H3 : (disjoint ?lv1 ?lv2) |- _ ]
      => apply H3 in H1; sp ; fail
  |  [ H1 : LIn ?t ?lv1 , H2 : LIn ?t ?lv2, H3 : (disjoint ?lv2 ?lv1) |- _ ]
      => apply H3 in H1; sp ;fail
     end.

Lemma in_nth3 :
  forall T a def (l:list T),
     LIn a l
    -> {n : nat $ (n < length l) # a = nth n l def}.
Proof.
  introv Hin. apply in_nth in Hin.
  exrepnd.
  exists n.
  dands; sp.
  rewrite nth_indep with (d':=a); sp.
Qed.

Lemma le_binrel_list_un : forall {T:Type} (def : T) 
   (R: @bin_rel T) (Rul Rur: T -> [univ]),
   le_bin_rel R (indep_bin_rel Rul Rur) 
   -> forall (la lb : list T), binrel_list def R la lb
          -> (forall x:T , LIn x la -> Rul x) # (forall x:T , LIn x lb -> Rur x).
Proof.
  introv Hle Hb. repnud Hle. repnud Hb. unfold indep_bin_rel in Hle.
  split;
  introv Hin; apply in_nth3 with (def:=def) in Hin; exrepnd;
    subst; dimp (Hb n); spc;
    apply Hle in hyp; sp.
Qed.

Lemma binrel_list_nil : forall {T : Type } R (def :T ), binrel_list def R nil nil.
Proof.
  introv. split;[sp | introv Hlt; simpl in Hlt; omega].
Qed.

Tactic Notation "spcf" :=
  try(spc;fail).

Lemma binrel_list_cons : forall {T : Type} R (def a b :T ) ta tb,
   (binrel_list def R ta tb # R a b)
   <=> (binrel_list def R (a::ta) (b :: tb)).
Proof.
  split; introv hyp; unfold binrel_list in hyp; unfold binrel_list.
  - repnd. 
    simpl. dands;spcf;[]. introv Hlt. destruct n; spc.
    dimp (hyp0 n); spc; omega.
  - allsimpl. repnd. dands ;spcf.
    + introv Hlt. dimp (hyp (S n));sp; omega.
    + dimp (hyp 0); spc; omega.
Qed.

Lemma in_combine_left_eauto :
  forall (A B : Type) a b,
  forall l1 : list A,
  forall l2 : list B,
     LIn (a,b) (combine l1 l2)
    ->  LIn a l1.
Proof.
  introv Hin. apply in_combine in Hin; spc.
Qed.
Ltac in_reasoning :=
match goal with 
| [ H : context [LIn _ [_]] |- _] => trw_h in_single_iff  H
| [ H : LIn _ (_::_) |- _ ] => simpl in H
| [ H : LIn _ (_++_) |- _ ] => apply in_app_iff
| [ H : _ [+] _ |- _] => destruct H as [H | H]
end.

Lemma in_combine_right_eauto :
  forall (A B : Type) a b,
  forall l1 : list A,
  forall l2 : list B,
     LIn (a,b) (combine l1 l2)
    ->  LIn b l2.
Proof.
  introv Hin. apply in_combine in Hin; spc.
Qed.

Ltac dLin_hyp := 
  repeat match goal with
  [ H : forall  x : ?T , ((( ?L = x ) [+] ?R) -> ?C) |- _ ] => 
    let Hyp := fresh "Hyp" in
    pose proof (H L (or_introl eq_refl)) as Hyp;
    specialize (fun x y => H x (or_intror y))
  | [ H : forall  x : ?T , False -> _ |- _ ] => clear H
  end.

Ltac dlist_len_name ll name :=
repeat match goal with
[  H : length ll  = _ |- _ ]=> symmetry in H 
|[ H :  0 = length ll |- _ ]  => destruct ll; inversion H
|[ H :  S _ = length ll |- _ ]  => 
    let ename:= fresh name in
    destruct ll as [| ename ll]; simpl in H; inverts H
|[ H :  0 = length [] |- _ ]  => clear H
end.

Ltac dlist_len ll := dlist_len_name ll ll.

Ltac dlists_len :=
repeat match goal with
|[ H :  0 = length ?ll |- _ ]  => dlist_len ll
|[ H :  S _ = length ?ll |- _ ]  => dlist_len ll
end.

Hint Resolve in_combine_left_eauto : slow.
Hint Resolve in_combine_right_eauto : slow.

Ltac destFind := match goal with
   [  |- context[find ?s ?v]] => 
  let sns := fresh v "s" in
  remember (find s v) as sn;
  let H := get_last_hyp tt in
  let H' := fresh H "l" in
  (destruct sn as [sns |];
  symmetry in H;
  try (pose proof (@find_some _ _ _ _  H) as H');
  try (pose proof (@find_none _ _ _  H) as H'))
  end.

Lemma no_repeats_as_disjoint : forall {A} (h:A) t,
  no_repeats (h::t)
  -> disjoint [h] t /\ no_repeats t.
Proof.
  intros ? ? ? Hnr.
  inverts Hnr.
  split; auto.
  intros ?. rewrite in_single_iff. intro H.
  subst. assumption.
Qed.

Lemma repeat_map_len : forall A B (b:B) (vs: list A) ,
  map (fun _ => b) vs = repeat (Datatypes.length vs) b.
Proof.
  induction vs; auto; simpl; f_equal; auto.
Qed.

Lemma map_eq_repeat_implies : forall A B (b:B) f (vs: list A) n,
  map f vs = repeat n b
  -> forall v, LIn v vs -> f v = b.
Proof.
  induction vs; intros; [simpl in *; tauto|].
  applydup (f_equal  (@length B)) in H.
  rewrite repeat_length in H1.
  simpl in *. destruct n;[omega|].
  simpl in *. inverts H. in_reasoning; subst; eauto.
Qed.
