global with sharing class Node 
{
    public Id NodeId{get;set;}
	public sObject Value{get;set;}
	public Id ParentId{get;set;}
	public Map<Id, Node> SubTrees{get;set;} 
	
	public Node(sObject s)
	{
		NodeId = s.Id;
		Value = s;
		SubTrees = new Map<Id, Node>();
	}
	
	public Node()
	{
		SubTrees = new Map<Id, Node>();
	}
}