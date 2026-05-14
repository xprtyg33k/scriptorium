# Document Vendor Integration Documentation and Replacement/ROI Plan

## Search log (commands and keywords used)

### Command log
1. `rg --files -g 'AGENTS.md'`
2. `rg -n "Accusoft|Apryse|Snowbound|VirtualViewer|PrizmDoc|RasterMaster|viewer|annotat|redact|watermark|tiff|pdf|IHttpHandler|HttpHandler|HttpModule|ScriptManager|UpdatePanel|ASMX|\.svc|packages.config|Directory.Packages.props|NuGet.config|angular.json|package.json|webpack|vite|react|App_Start|Global.asax|web\.config" --glob '!**/bin/**' --glob '!**/obj/**'`
3. `find . -maxdepth 2 -type d | sort`
4. `rg -n "VirtualViewer|Snowbound|Accusoft|Prizm|RasterMaster|Apryse|Dynamsoft|document viewer|viewer" ...`
5. `rg -n "VirtualViewer|EpsDocumentViewer|DocumentViewer|documentId|clientInstanceId|Dynamsoft|Scanning|tiff|annotation|annotat|redact|stamp|watermark" PVM.Web PVM.Web.Tests ...`
6. `find PVM.Web -path '*EpsDocumentViewer*' -o -path '*EPSDocumentViewer*' | sort`
7. File inspections with `nl -ba ... | sed -n 'start,endp'` for all primary integration files.
8. `rg -n "OpenDocumentViewer|SetupDocumentViewer|hdnEpsDocumentUrl|ifrmDialogDocumentViewer|dialogDocumentViewer|DocumentViewer.js|EpsDocumentViewer.aspx\?clientInstanceId" ...`
9. `rg -n "SubmitTransfer|EOBFilenameExist|hdnDocumentViewerUrl|hdnEpsDocumentUrl|EPSdialogDocumentViewer|EPSifrmDialogDocumentViewer|postMessage" PVM.Web ...`
10. `find . -name package.json -o -name angular.json -o -name yarn.lock -o -name pnpm-lock.yaml -o -name package-lock.json -o -name webpack.config.js -o -name vite.config.js | sort`
11. `rg -n "AngularApps/BillingApp|BillingApp/dist|BillingApp" ...`
12. `rg -n "PVFileContentHandler|getDocumentContent|VirtualViewerNetHTML5|documentId=|clientInstanceId=|eobflag" PVM.Web PVM.Web.Tests ...`

### Keyword set used
- Vendor-specific: `Accusoft`, `Apryse`, `Snowbound`, `VirtualViewer`, `PrizmDoc`, `RasterMaster`, `Dynamsoft`.
- Generic doc ops: `viewer`, `document`, `pdf`, `tiff`, `render`, `convert`, `annotate`, `stamp`, `redact`, `watermark`, `documentId`.
- WebForms pipeline: `HttpHandler`, `IHttpHandler`, `HttpModule`, `web.config handlers`, `ScriptManager`, `UpdatePanel`, `.svc`.
- Front-end/build: `package.json`, `angular.json`, `webpack`, `vite`, `react`, `dist`, `bundle`.

---

## Deliverable A: Integration documentation

## A.1 Executive summary

### Facts (evidence-backed)
- The active third-party document viewer integration is an externally hosted **Virtual Viewer** endpoint configured as `VirtualViewerURL` and embedded through an iframe (`EPSDocumentViewer.aspx`), with URL parameters that include `clientInstanceId` and (for record-level loads) `documentId`.
- The viewer endpoint is selected via LaunchDarkly flag `VirtualViewerURL`, with fallback to integration-endpoint lookup (`EndpointManagerService`) if the flag returns `FALSE`.
- Primary business workflows using this integration:
  1. EPS Work Detail document editing flow (`EPSWorkDetail.aspx` -> `EpsDocumentViewer.aspx` -> external Virtual Viewer URL).
  2. Patient AR/ERA transfer EOB workflow (sets session/cookies and opens modal viewer dialog).
  3. Query/report context viewer dialog reuse.
  4. Master-page-level reusable dialog for document viewer launch.
- Coupling depth is **medium-tight**:
  - There is a small wrapper/controller layer (`EpsDocumentViewerController`) that assembles URL/query parameters.
  - Functional behavior (viewer UI, annotation/editor actions, document retrieval callback semantics) is externalized to the vendor endpoint; local app depends on specific query semantics (`documentId` presence).
- Runtime note in code comments states `documentId` is necessary to trigger `getDocumentContent()` in `PVFileContentHandler.dll`, which is not present in this repository.

### Not found in repository
- No vendor SDK package name (e.g., Accusoft/Apryse/Snowbound) for the Virtual Viewer is declared in `packages.config` or project references.
- No local source for `PVFileContentHandler.dll` and no direct implementation of `getDocumentContent()`.
- No direct in-repo API contract for annotation payload schemas to/from the external viewer.
- No explicit vendor license key for Virtual Viewer in web config files.

## A.2 Dependency inventory table

| Dependency instance | Type | Declared where | Runtime load/invocation | License/activation evidence | Environments impacted |
|---|---|---|---|---|---|
| Virtual Viewer (external endpoint `VirtualViewerURL`) | External web app/service | `web.config.*-DIFF.xml` appSettings `VirtualViewerURL`; LaunchDarkly flag enum entry | `EpsDocumentViewerController.GetIframeDocumentViewerSrc()` builds `<VirtualViewerURL>?clientInstanceId=...&documentId=...`; iframe `src` in `EPSDocumentViewer.aspx` | No explicit license key in repo for Virtual Viewer; endpoint is retrieved by integration endpoint service when LD flag false | DEV, DV2-5, INT, INT02, STAGE/ST2-5, PROD, BETA, E01, HITACHI, KANBAN |
| Integration endpoint fallback for viewer | Internal endpoint registry service | `IntegrationEndpointHelper.GetIntegrationEndpointForVirtualViewer` | Used by master pages, Query page, EPS controllers when LD returns `FALSE` | Uses endpoint registry entity (`IntegrationEndpointEntity`) including `EndpointPassword` field in helper model; no direct viewer key material in repo | All environments where LD fallback path used |
| EpsDocumentViewer wrapper page/controller | Local WebForms wrapper | `EPSDocumentViewer.aspx`, `EpsDocumentViewer.aspx.cs`, `PageHelpers/EpsDocumentViewer/*` | Route `EpsDocumentViewer.aspx` is opened in modal iframe from master pages and EPSWorkDetail | No license handling in wrapper | All app environments |
| Dynamsoft scanning assets/config (adjacent document pipeline, not viewer iframe vendor) | JS/CSP/CDN + appSettings | `Web.config` (`DynamsoftProductKey`, `DynamsoftVersion`), `Scripts/Scanning/*`, `PymtDetail.aspx.cs` | Loaded for scanning setup (separate from Virtual Viewer flow) | Product key placeholder in config | Same transformed environments with Dynamsoft keys |

## A.3 Integration points catalog

### Integration ID: VV-01 (Viewer host page)
- **Project area:** WebForms page.
- **File paths:**
  - `PVM.Web/EPSDocumentViewer.aspx`
  - `PVM.Web/EpsDocumentViewer.aspx.cs`
  - `PVM.Web/PageHelpers/EpsDocumentViewer/EPSDocumentViewerController.cs`
  - `PVM.Web/PageHelpers/EpsDocumentViewer/EPSDocumentViewerDataStore.cs`
- **Entry points:**
  - Page lifecycle: `EpsDocumentViewer.Page_Load`, `OnInit`.
  - Controller method: `GetIframeDocumentViewerSrc()`.
- **Call chain summary:**
  1. WebForms route `EpsDocumentViewer.aspx` loads.
  2. `Page_Load` calls controller `HandlePageLoad(Request)`.
  3. Controller parses `clientInstanceId` query string (`practice`, `clinic/invoice`, `chartPk`, optional additional tokens).
  4. Controller resolves viewer base URL (LaunchDarkly -> IntegrationEndpoint fallback).
  5. For chart workflow (`count==3`) it fetches `ChartDocumentHeaderEntity` via `WorkCompAttachmentManagerService.GetMedicalRecordDocument` and builds `documentId` from filename.
  6. For invoice workflow (`count==4` or `7`) it calls `DocRegistryManagerService.GetInvoiceEOBFileName` and uses that value for `documentId`.
  7. Returns iframe URL to external Virtual Viewer.
- **Input/output formats:**
  - Input query parameter format: `clientInstanceId` colon-delimited string with 3, 4, or 7 tokens.
  - Output: URL string `<VirtualViewerURL>?clientInstanceId=...[:UserId]&documentId=<filename>`.
  - File naming patterns observed: `.tif/.tiff` (test mock returns `.tiff`; comments/reference URLs show `.tif`), plus EOB filenames from registry.
- **Config/secrets wiring:**
  - LaunchDarkly flag `VirtualViewerURL` controls endpoint override.
  - Fallback endpoint from `IntegrationEndpointHelper.GetIntegrationEndpointForVirtualViewer(practice)`.
- **Environment behavior:**
  - Endpoint domain differs per transformed config (`devvirtualviewer`, `stvirtualviewer`, `intvirtualviewer`, `virtualviewer` prod).
- **Error/edge behavior:**
  - Invalid query format: logs + throws `ArgumentException`.
  - Missing chart header or filename: logs and falls back to URL without `documentId`.
  - Missing EOB filename: logs and falls back to default URL.
- **Observability:**
  - `PVMLogger` emits error logs with context fields (`Practice`, `ChartPk`, `Invoice Number`).

### Integration ID: VV-02 (Master/Query modal launcher)
- **Project area:** Shared WebForms master pages + Query page.
- **File paths:**
  - `PVM.Web/PvmMaster.Master`, `PVM.Web/PvmMaster.Master.cs`
  - `PVM.Web/PVM.NewStandards.Master.cs`
  - `PVM.Web/Query.aspx`, `PVM.Web/Query.aspx.cs`
  - `PVM.Web/PageHelpers/Common/DocumentViewer.js`
- **Entry points:**
  - `Page_Load` in master/query code-behind sets hidden fields:
    - `hdnDocumentViewerUrl` = viewer origin (scheme+host+port)
    - `hdnEpsDocumentUrl` = local wrapper URL `EpsDocumentViewer.aspx?clientInstanceId=...`
  - JavaScript functions `SetupDocumentViewer()`, `OpenDocumentViewer()`.
- **Call chain summary:**
  1. Page loads and server computes viewer host + wrapper URL.
  2. JS checks cookies (`SubmitTransfer`, `EOBFilenameExist`) and opens jQuery dialog containing iframe.
  3. Iframe `src` points to `hdnEpsDocumentUrl` (local wrapper page).
  4. Wrapper page redirects iframe to external Virtual Viewer URL.
  5. `window.message` handler only accepts messages from hidden viewer origin and closes dialog.
- **Input/output formats:**
  - Cookies: Boolean string values `True/False`.
  - Hidden fields: URL strings.
- **Config/secrets wiring:**
  - Same LaunchDarkly + IntegrationEndpoint fallback as VV-01.
- **Environment behavior:**
  - Viewer host/port differs by transform and endpoint registry.
- **Error/edge behavior:**
  - If EOB cookie false: modal not opened; user message “Unable to create documents as no EOB attached to Batch.”
  - On close, cookies are cleared.
- **Observability:**
  - UI-only; no explicit logging in JS helper.

### Integration ID: VV-03 (EPS Work Detail workflow integration)
- **Project area:** EPS work queue/detail.
- **File paths:**
  - `PVM.Web/EPSWorkDetail.aspx`, `PVM.Web/EPSWorkDetail.aspx.cs`
  - `PVM.Web/PageHelpers/EPSWorkDetail/EPSWorkDetailController.cs`
- **Entry points:**
  - `EPSWorkDetailController.HandlePageLoad()` -> `HandlePageInitialLoad()`.
- **Call chain summary:**
  1. Controller loads queue context and chart/practice IDs.
  2. Controller resolves viewer host endpoint and sets `VirtualViewerUrl` hidden field.
  3. Controller sets `EpsDocumentUrl` to `EpsDocumentViewer.aspx?clientInstanceId={practice}:{clinic}:{chartPk}`.
  4. UI uses dialog iframe (`EPSdialogDocumentViewer` / `EPSifrmDialogDocumentViewer`) to open viewer.
- **Input/output formats:**
  - `clientInstanceId` 3-token chart flow.
- **Config/secrets wiring:**
  - LaunchDarkly `VirtualViewerURL` + endpoint fallback.
- **Environment behavior:**
  - Endpoint host varies per env.
- **Error behavior:**
  - General try/catch in page load logs and surfaces generic UI error.
- **Observability:**
  - Controller logging via `PVMLogger`; user action audit writes.

### Integration ID: VV-04 (Patient AR ERA transfer trigger)
- **Project area:** Patient Accounts Receivables detail workflow.
- **File paths:**
  - `PVM.Web/PageHelpers/PatientAccountsReceivablesDetail/PatientAccountsReceivablesDetailController.cs`
  - `PVM.Web/PageHelpers/Common/DocumentViewer.js` (or inlined equivalent in `PvmMaster.Master` / `Query.aspx`)
- **Entry points:**
  - `primaryEOBAttachment()` in controller.
- **Call chain summary:**
  1. Finds ERA-linked payment and batch context.
  2. Sets session values for invoice/batch/payer and updates master hidden field `hdnEpsDocumentUrl` with wrapper URL.
  3. Checks EOB filename via datastore.
  4. Sets response cookies `SubmitTransfer` and `EOBFilenameExist`.
  5. Client-side script reads cookies and opens viewer dialog if valid.
- **Input/output formats:**
  - Session variables: practice/invoice/batch/payer.
  - Cookie booleans.
- **Config/secrets wiring:**
  - indirect through wrapper/controller resolution.
- **Error behavior:**
  - Missing EOB -> cookie false -> UI warning.
- **Observability:**
  - Controller logger available in surrounding class; this method primarily state mutation.

## A.4 System diagram narrative

### Components
1. WebForms UI pages/master pages (`PvmMaster`, `Query`, `EPSWorkDetail`).
2. Local wrapper page `EpsDocumentViewer.aspx` + controller/data store.
3. Internal services:
   - `DocRegistryManagerService` (EOB file lookup)
   - `WorkCompAttachmentManagerService` (chart doc lookup)
   - `EndpointManagerService` (endpoint resolution)
   - LaunchDarkly helper (feature flag URL override)
4. External viewer service (`VirtualViewerURL`) hosted outside this repository.
5. Browser modal/iframe and `postMessage` close flow.

### Data flow
- User action triggers workflow that sets session/cookies + hidden fields.
- Browser opens local iframe route (`EpsDocumentViewer.aspx`) first.
- Server composes remote viewer URL with `clientInstanceId` and optional `documentId`.
- Browser then loads external viewer page.
- Viewer-origin message closes modal after action completion.

### Trust boundaries
- Boundary A: App server -> endpoint registry / LaunchDarkly.
- Boundary B: Browser page origin -> external viewer origin (cross-origin iframe + `postMessage`).
- Boundary C: Viewer service -> downstream content provider (`PVFileContentHandler.dll` implied by comments; not in repo).

### Storage interactions
- Database-backed lookup for chart/EOB filenames through manager services.
- Optional S3-related EOB metadata packed into `eobflag` flows by doc registry code.
- Session + cookie state orchestrates viewer launch behavior.

### Failure modes/fallbacks
- Missing/invalid query params -> logged error, exception.
- Missing filename -> default URL without `documentId` (viewer may still load but may not fetch doc content).
- Missing EOB file -> UI warning and no launch.
- Endpoint resolution failure path is not strongly guarded against null URI in all call sites.

## A.5 Test coverage and confidence

### Existing tests
- `PVM.Web.Tests/EpsDocumentViewer/EpsDocumentViewerTests.cs` contains tests for controller URL assembly behavior, but key tests are disabled/ignored (`[Ignore]` and commented test).
- Mock datastore validates chart filename behavior (`chartPk + ".tiff"`).

### Coverage gaps
- No active tests asserting current `clientInstanceId` shape permutations (3/4/7 token paths) end-to-end.
- No tests for fallback behavior when LaunchDarkly returns `FALSE` and endpoint registry is used.
- No tests for cookie-driven modal open/close flow.
- No contract tests for viewer-origin `postMessage` restrictions.
- No characterization tests for `documentId` omission behavior vs vendor-side fetch outcomes.

### Characterization tests to add before refactor
1. URL composer tests for all token-count variants + malformed input.
2. Integration-style test mocking datastore to verify `documentId` inclusion and fallback.
3. UI behavior tests for cookie gate and dialog lifecycle.
4. Security test ensuring only `hdnDocumentViewerUrl` origin may close modal.
5. Regression test around EOB `eobflag` parsing and file-name extraction.

---

## Deliverable B: Replacement and ROI plan

## B.1 Functional parity matrix

| Confirmed current capability (fact) | Evidence | Priority | Parity requirement |
|---|---|---|---|
| Launch external viewer in modal dialog/iframe | master/query JS + iframe wrapper pages | Must-have | Same modal UX with close signaling and origin checks |
| Load document by `clientInstanceId` and `documentId` query contract | `EpsDocumentViewerController.GetIframeDocumentViewerSrc` | Must-have | New adapter must accept same upstream context and resolve concrete file IDs |
| Support chart docs (3-token flow) and EOB docs (4/7-token flow) | EPS controller + EpsDocumentViewer controller branches | Must-have | Preserve all 3/4/7 token entry paths until callers migrated |
| Handle missing EOB/file gracefully with user message/fallback URL | Patient AR + JS helper + controller fallbacks | Must-have | Preserve clear user feedback and non-crashing behavior |
| Environment-specific endpoint routing | web.config transforms + endpoint helper | Must-have | Maintain environment-aware endpoint config and feature-flag override |
| Viewer editor operations (copy/select/send) visible in embedded tool | Instructions in `EPSDocumentViewer.aspx` | Should-have | Equivalent end-user actions or documented substitute workflow |
| Annotation fidelity (redact/highlight/stamp/signatures) | **Not found in repository as explicit API contracts** | Input required | Define required annotation set with business owners before cutover |
| Browser support constraints | **Not found in repository as explicit matrix** | Input required | Baseline from production support policy |
| Compliance requirements | **Not found in repository** | Input required | Define retention/audit/compliance controls for document edits |

Performance and render-fidelity targets are **input required** (not found in repository as numeric SLO/SLA).

## B.2 Replacement options (3)

## Option 1: Adapter-first, replace external viewer with internal document service + OSS web viewer
- **Architecture:** Wrapper/adapter + phased swap (strangler).
- **Technology approach:** Internal `IDocumentViewerService` abstraction; OSS viewer frontend; internal document render endpoint.
- **Integration plan:**
  1. Introduce interface (`IDocumentOps`) behind `EpsDocumentViewerController`.
  2. Keep current Virtual Viewer adapter as default implementation.
  3. Add new implementation returning local viewer route + signed document fetch API.
  4. Migrate call sites to interface-based URL factory.
  5. Roll out by feature flag (practice cohorts) and canary.
- **Risks:** rendering fidelity drift; annotation feature gaps; cross-browser behavior.
- **Mitigations:** characterization tests + golden-image comparison + staged cohort rollout.
- **Backout:** flip flag to existing Virtual Viewer adapter.

### ROI model (18 months)
- `AvoidedCost18 = VendorCost18 + AvoidedOperationalOverhead18`
- `ImplementationCost18 = Eng + QA + SecComp + DevOps + TestBackfill + Tooling`
- `RunDelta18 = NewRunCost18 - CurrentRunCost18`
- `NetBenefit18 = AvoidedCost18 - ImplementationCost18 - RunDelta18`
- **Positive gate condition:** `ImplementationCost18 < AvoidedCost18 - RunDelta18`
- **Status:** `VendorCost18`, role rates, run-cost deltas are **input required**.

## Option 2: Commercial vendor swap behind stable abstraction (lowest migration risk)
- **Architecture:** Adapter + phased vendor replacement.
- **Technology approach:** New commercial viewer vendor with explicit API SLAs; keep wrapper route shape stable.
- **Integration plan:**
  1. Add `IExternalViewerProvider` abstraction.
  2. Keep query-contract compatibility (`clientInstanceId`, `documentId`) at wrapper boundary.
  3. Implement provider A=current, provider B=new.
  4. Dual-run shadow mode for URL generation and response validation.
  5. Feature-flag rollout by practice/environment.
- **Risks:** new licensing cost may reduce ROI; contract lock-in.
- **Mitigations:** procurement cap + exit clauses + abstraction retention.
- **Backout:** switch provider flag to current vendor.

### ROI model (18 months)
- Same formulas.
- **Positive gate condition:** `(CurrentVendorCost18 - NewVendorCost18 + AvoidedOps18) > (Implementation + Migration + RunDelta)`.
- **Status:** Current/new vendor price cards and implementation hours are **input required**.

## Option 3: Service extraction with document processing microservice + gradual UI replacement
- **Architecture:** Service extraction + long-term rewrite of viewer UI surface.
- **Technology approach:** Internal document microservice for resolve/render/annotation APIs; WebForms uses iframe/app shell during transition.
- **Integration plan:**
  1. Extract document lookup and URL compose logic from page controllers to service layer.
  2. Introduce API contracts for document fetch, page render, annotation save.
  3. Keep `EpsDocumentViewer.aspx` as compatibility shell initially.
  4. Replace modal iframe target to internal UI endpoint.
  5. Decommission external vendor dependency once parity complete.
- **Risks:** highest upfront cost, longest schedule.
- **Mitigations:** milestone gates, strict non-functional requirements, parallel run.
- **Backout:** retain compatibility shell + current vendor adapter until final cutover.

### ROI model (18 months)
- Same formulas.
- **Positive gate condition:** often requires larger avoided-cost base or broader platform reuse benefits.
- **Status:** Without confirmed current vendor spend and projected infra/support cost, quantitative ROI is **input required**.

## B.3 ROI assumptions, sensitivity, and payback

Because actual cost inputs are not present in the repository, numeric ROI values are not evidence-derivable.

### Inputs required to compute actual ROI
1. Current vendor contract total over 18 months (license + seats + maintenance + support incidents).
2. Role-based loaded rates and estimated hours (Eng, QA, Sec/Compliance, DevOps, PM).
3. Incremental run costs (compute/storage/observability/support).
4. Expected avoided operational overhead from current integration.

### Sensitivity template (for each option)
- **Best case:** high avoided cost, low implementation, low run delta.
- **Expected case:** mid avoided cost, realistic implementation, neutral run delta.
- **Worst case:** lower avoided cost, overrun implementation, positive run delta.

### Payback month formula
- `MonthlyNetBenefit = (AvoidedCost18 - RunDelta18)/18`
- `PaybackMonth = ceil(ImplementationCost18 / MonthlyNetBenefit)`
- Accept only if `NetBenefit18 > 0` and payback month <= 18.

## B.4 Delivery plan and milestones

1. **Milestone 0: Characterization baseline**
   - Scope: tests for URL contract/cookie gates/origin message handling.
   - Exit: passing characterization suite in CI.
   - Evidence: test artifacts + baseline fixtures.
   - Risk reduced: unknown behavior during swap.

2. **Milestone 1: Internal abstraction layer**
   - Scope: introduce `IDocumentOps` + current vendor adapter.
   - Exit: no direct vendor URL construction outside adapter.
   - Evidence: dependency graph + call site migration PRs.
   - Risk reduced: lock-in and spread coupling.

3. **Milestone 2: New implementation (parallel run)**
   - Scope: implement candidate replacement provider/service.
   - Exit: shadow mode parity reports pass thresholds.
   - Evidence: parity diff report, render/annotation checks.
   - Risk reduced: functional regressions.

4. **Milestone 3: Canary rollout**
   - Scope: enable for selected practices/cohorts.
   - Exit: SLO/error-rate within agreed bounds for canary period.
   - Evidence: logs/metrics, support ticket trend.
   - Risk reduced: broad production blast radius.

5. **Milestone 4: Full cutover + decommission**
   - Scope: all traffic switched; old vendor path dormant.
   - Exit: contract termination readiness + rollback contingency retained for one release cycle.
   - Evidence: release checklist, runbook updates.
   - Risk reduced: residual hidden dependency.

## B.5 Recommendation

### Fact-constrained recommendation
Given current repository evidence, the best starting path is **Option 1 (adapter-first strangler)** because:
1. It directly matches existing coupling shape (central URL builder + wrapper page).
2. It minimizes initial blast radius and preserves backout simplicity.
3. It enables measurable parity before committing to full platform rewrite.

Final option selection among Option 1 vs Option 2 requires missing commercial inputs (current vendor 18-month cost and replacement licensing proposals) to prove positive ROI numerically.

---

## Appendix: Evidence index

### Core integration files
- `PVM.Web/EPSDocumentViewer.aspx`
- `PVM.Web/EpsDocumentViewer.aspx.cs`
- `PVM.Web/PageHelpers/EpsDocumentViewer/EPSDocumentViewerController.cs`
- `PVM.Web/PageHelpers/EpsDocumentViewer/EPSDocumentViewerDataStore.cs`
- `PVM.Web/PageHelpers/EpsDocumentViewer/Interface/IEPSDocumentViewerController.cs`
- `PVM.Web/PageHelpers/EpsDocumentViewer/Interface/IEPSDocumentViewerDataStore.cs`

### Launch/config wiring
- `PVM.Web/Helpers/LaunchDarkly/LaunchDarklyFlags.cs`
- `PVM.Web/Helpers/IntegrationEndpointHelper.cs`
- `PVM.Web/Web.config`
- `PVM.Web/web.config.DEV-DIFF.xml`
- `PVM.Web/web.config.DV2-DIFF.xml`
- `PVM.Web/web.config.DV3-DIFF.xml`
- `PVM.Web/web.config.DV4-DIFF.xml`
- `PVM.Web/web.config.DV5-DIFF.xml`
- `PVM.Web/web.config.INT-DIFF.xml`
- `PVM.Web/web.config.INT02-DIFF.xml`
- `PVM.Web/web.config.STAGE-DIFF.xml`
- `PVM.Web/web.config.ST2-DIFF.xml`
- `PVM.Web/web.config.ST3-DIFF.xml`
- `PVM.Web/web.config.ST4-DIFF.xml`
- `PVM.Web/web.config.ST5-DIFF.xml`
- `PVM.Web/web.config.PROD-DIFF.xml`
- `PVM.Web/web.config.BETA-DIFF.xml`
- `PVM.Web/web.config.E01-DIFF.xml`
- `PVM.Web/web.config.HITACHI-DIFF.xml`
- `PVM.Web/web.config.KANBAN-DIFF.xml`

### Workflow launch points
- `PVM.Web/PvmMaster.Master`
- `PVM.Web/PvmMaster.Master.cs`
- `PVM.Web/PVM.NewStandards.Master.cs`
- `PVM.Web/Query.aspx`
- `PVM.Web/Query.aspx.cs`
- `PVM.Web/EPSWorkDetail.aspx`
- `PVM.Web/EPSWorkDetail.aspx.cs`
- `PVM.Web/PageHelpers/EPSWorkDetail/EPSWorkDetailController.cs`
- `PVM.Web/PageHelpers/Common/DocumentViewer.js`
- `PVM.Web/PageHelpers/PatientAccountsReceivablesDetail/PatientAccountsReceivablesDetailController.cs`

### Build/runtime context
- `PVM.Web/App_Start/BundleConfig.cs`
- `PVM.Web/Global.asax.cs`
- `PVM.Web/packages.config`
- `PVM.Web/PVM.Web.csproj`
- `PVM.Web/AngularApps/BillingApp/package.json`
- `PVM.Web/AngularApps/BillingApp/angular.json`
- `PVM.Web/Controls/BillingAppControl.ascx`
- `PVM.Web/BillingTask.aspx`

### Tests
- `PVM.Web.Tests/EpsDocumentViewer/EpsDocumentViewerTests.cs`
- `PVM.Web.Tests/EpsDocumentViewer/Mocks/EpsDocumentViewerDataStoreMock.cs`

### Explicit “not found in repository” checks
- Searched for direct Virtual Viewer SDK package names and local DLLs (Accusoft/Apryse/Snowbound/PrizmDoc/RasterMaster): not found.
- Searched for `PVFileContentHandler.dll` implementation and `getDocumentContent()` source: not found.
- Searched for explicit annotation API payload contracts (redaction/highlight/stamp/signature endpoints): not found.
- Searched for explicit Virtual Viewer license key/app setting: not found.
