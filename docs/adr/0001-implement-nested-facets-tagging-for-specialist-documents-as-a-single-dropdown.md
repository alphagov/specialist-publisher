# 1. Implement nested facets tagging for specialist documents as a single dropdown

Date: 2025-02-14

## Status

Proposed

## Related PRs

- [Implemented as part of this PR](https://github.com/alphagov/specialist-publisher/pull/2923)

## Context

Nested facets are required by a department as part of their new finder. Their existing finder contains: 

- For filtering, a "Facet" dropdown and a "Sub facet" dropdown to filter for documents. Users are able to filter through a single facet value lookup at a time. 
- The documents are tagged with multiple Facet and Sub facet values

We need to be able to replicate this behaviour with minimal efforts to meet a deadline. 

## Decision

What we have implemented:

- On the publisher side for tagging, a single dropdown that merges the facets' values (main facet and sub facets, essentially leaf nodes).
  - we allow main facets to be defined without subfacets. It would show up in the dropdown if that is the case. For the initial finder we are creating, they don't have any main facet value with no sub-facets. 
  - if the main facet has sub-facets, then you can only choose the sub-facets (leaf nodes). We don't allow tagging of main facet if the value has sub-facets available. Reason being we still have things to clarify about that behaviour (is it equivalent to tagging all subs, or no subs). Since the current finder doesn't require it, we de-scope this further down the line.
- When we send the document to Publishing API, we write logic into the document model to figure out whether the leaf node is a parent facet or sub-facet value in the dropdown, and split the metadata we send to Publishing API into its own facet and a separate sub-facet in `specialist-publisher/app/models/document.rb` 
  - Reasons for this being if we send them as separate facets, we can keep Publishing API and Search API functionality unchanged. 
- When we load the edit page or new page again, the document is loaded from Publishing API, with the facet and sub-facet being separate facets, but the dropdown element expects a combined leaf node dropdown as mentioned in the first point, so we have to merge them back together again into the main facet field in `specialist-publisher/app/controllers/documents_controller.rb`.

## Consequences

Pros: 

- Restrict user input to only valid options with a single dropdown. 
- This supports both multiple select entries and single select entries. 
- The workflow discussed as part of analysis document works.

Cons:

- Logic to merge the parent facet values, sub-facet values at form phase, split them at send phase, merge them again at load phase might be a little convoluted.

## Alternatives proposed

### Have tagging done as 2 separate facets with validation 

Even on publisher side, surface all of a facet's parents facets as one dropdown, and all of the sub-facets as a separate dropdown. As outlined on [this commit](https://github.com/alphagov/specialist-publisher/commit/c7346db771df5ccafd5fff8f7f687a8211436f6a).

Pros:

- Consistency of 2 separate facets being displayed to users upon tagging and viewing metadata. 
- No change logic required to split or merge facets

Cons:

- Repeat of information. The sub-facets are also prefixed with parent facet in any case (e.g. to differentiate between multiple "Not Applicable" sub-facet entries). Users will have to tag both parent facet and the sub-facet with the prefix. 
- There is no structural tie between the parent facet and the sub-facet when tagging. Nothing stopping the user from tagging mismatching pairs or not tagging a sub-facet. 
  - In order to get around this, we would have to implement some validation on the backend to ensure users are adding correct pairs.

### Remove support for "mixed" leaf nodes and only support sub-facet entry only

The finder we are supporting as MVP do not require the need to support a mixture of top level parent facet values and sub-facet values. We could try and simplify by only having the dropdown of only sub-facets from a given facet. 

Pros:

- No requirement to figure out whether a parameter value is a parent facet node or sub-facet node. We can assume all parameters of a nested-facet type field is a sub-facet value
- Consistency of saving and loading data as we are consistently working with sub-facets and the only logic required is to additionally tag parent-facet upon saving. 

Cons:

- Does not support scenarios of "mix leaf node" where some facet values do not have sub-facets.