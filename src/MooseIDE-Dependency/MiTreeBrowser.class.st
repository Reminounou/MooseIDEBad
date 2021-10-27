"
Shows the containment tree (direct relations for now) between the entities.

- Follow: Accepts a MooseEntity using TEntityMetaLevelDependency.
- Highlight: Entities if present.
- Propagate: <TODO>
"
Class {
	#name : #MiTreeBrowser,
	#superclass : #MiAbstractDependencyBrowser,
	#instVars : [
		'tree'
	],
	#category : #'MooseIDE-Dependency-Tree'
}

{ #category : #specs }
MiTreeBrowser class >> defaultSpec [
	^ super defaultSpec
		add: #tree;
		yourself
]

{ #category : #specs }
MiTreeBrowser class >> menuCommandOn: aBuilder [
	<worldMenu>
	<miBrowsers>
	(aBuilder item: #TreeBrowser)
		parent: self toolbarDependencyName;
		label: self title;
		order: 1.0;
		icon: (self iconNamed: #mooseTree);
		help: self helpMessage;
		action: [ self open ]
]

{ #category : #'as yet unclassified' }
MiTreeBrowser class >> newModel [

	^ MiTreeBrowserModel new
]

{ #category : #specs }
MiTreeBrowser class >> open [
	<script>
	^ super open
]

{ #category : #'as yet unclassified' }
MiTreeBrowser class >> title [
	^ 'Tree'
]

{ #category : #testing }
MiTreeBrowser >> canReceiveEntity: anObject [

	^ anObject usesFamixTrait: TEntityMetaLevelDependency
]

{ #category : #actions }
MiTreeBrowser >> followEntity: anEntity [

	self model root: anEntity.
	self model selected: anEntity.

	self refreshTree
]

{ #category : #initialization }
MiTreeBrowser >> initializePresenters [

	tree := self newTreeTable.
	tree
		addColumn: (SpCompositeTableColumn new
				 addColumn: ((SpImageTableColumn evaluated: #midasIcon)
						  width: 20;
						  yourself);
				 addColumn: (SpStringTableColumn evaluated: #name);
				 yourself);
		children: [ :aClass | aClass children asOrderedCollection ];
		beMultipleSelection;
		beResizable.
	tree whenSelectedItemChangedDo: [ :entityOrGroup | 
		self freezeDuring: [ 
			model selected: entityOrGroup mooseInterestingEntity.
			self buses do: [ :bus | bus globallySelect: entityOrGroup ] ] ]
]

{ #category : #accessing }
MiTreeBrowser >> miSelectedItem [

	^ model selected
]

{ #category : #actions }
MiTreeBrowser >> refreshTree [

	tree
		roots: { self model root };
		expandPath: #( 1 ).

	self freezeDuring: [ tree selectItem: model root ]
]