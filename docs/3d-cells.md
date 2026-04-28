# Standard Cells in 3D

This page shows 3D visualizations of standard cells used by four different open source PDKs (<a href="#asap7">ASAP7</a>, <a href="#nangate45">nangate45</a>, <a href="#sky130">Skywater130</a>, and <a href="#sky130hd">Skywater130 High Density</a>). Standard cells are the building blocks that the EDA software puts together to make a chip layout out of the SytemVerilog design you write.

The following are selected standard cells in the 7nm ASAP7 PDK. You can drag to rotate and scroll to zoom. To generate them from our Docker container, run:

```bash
make show_3d_cell              # show all available cells
make show_3d_cell CELL=NAND2x1 # show NAND2x1
```

```{raw} html
<style>
  .week1-cell-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
    margin: 1.25rem 0 1.75rem;
  }

  .week1-cell-card {
    margin: 0;
  }

  .week1-cell-viewer {
    width: 100%;
    height: clamp(14rem, 24vw, 18rem);
    background: transparent;
    border: 1px solid #d7dee8;
    border-radius: 0.75rem;
  }

  .week1-cell-card .model-viewer-fallback-host {
    width: 100%;
    height: clamp(14rem, 24vw, 18rem);
    border: 1px solid #d7dee8;
    border-radius: 0.75rem;
    background: transparent;
  }

  .week1-cell-card .hero-model-fallback {
    width: 100%;
    height: 100%;
  }

  .week1-cell-card .hero-model-fallback-image {
    width: 100%;
    height: 100%;
    object-fit: contain;
    display: block;
    background: transparent;
  }

  .week1-cell-card figcaption {
    margin-top: 0.55rem;
    text-align: center;
    font-size: 0.95rem;
  }

  .pdk-panel {
    margin: 0.85rem 0 2rem;
    padding: 1rem;
    border-radius: 0.75rem;
    background: transparent;
    color: inherit;
    opacity: 0.96;
  }

  .pdk-controls {
    margin-bottom: 0.85rem;
    display: flex;
    align-items: center;
    gap: 0.7rem;
    flex-wrap: nowrap;
  }

  .pdk-label {
    display: inline-block;
    margin: 0;
    font-size: 0.9rem;
    font-weight: 600;
    white-space: nowrap;
  }

  .pdk-select {
    width: 100%;
    max-width: 28rem;
    padding: 0.5rem 0.65rem;
    border: 1px solid var(--color-border, currentColor);
    border-radius: 0.5rem;
    background: var(--color-background-secondary, #ffffff);
    color: var(--color-foreground-primary, #111111);
    font-size: 0.95rem;
  }

  .pdk-select option {
    background: var(--color-background-secondary, #ffffff);
    color: var(--color-foreground-primary, #111111);
  }

  .pdk-viewer {
    width: 100%;
    height: clamp(16rem, 30vw, 23rem);
    background: transparent;
    border-radius: 0.75rem;
  }

  .pdk-panel .model-viewer-fallback-host {
    width: 100%;
    height: clamp(16rem, 30vw, 23rem);
    border-radius: 0.75rem;
    background: transparent;
  }

  .pdk-panel .hero-model-fallback {
    width: 100%;
    height: 100%;
  }

  .pdk-panel .hero-model-fallback-image {
    width: 100%;
    height: 100%;
    object-fit: contain;
    display: block;
    background: transparent;
  }

  @media (max-width: 900px) {
    .week1-cell-grid {
      grid-template-columns: 1fr;
    }
  }
</style>

<section class="week1-cell-grid">
  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="https://media.abapages.com/course-site/asap7/INVx1_ASAP7_75t_R.glb"
      alt="NOT gate standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 2m"
      field-of-view="30deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/asap7/INVx1_ASAP7_75t_R.png"
          alt="NOT gate standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="https://media.abapages.com/course-site/asap7/INVx1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>NOT gate (INVx1)</figcaption>
  </figure>

  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="https://media.abapages.com/course-site/asap7/NAND2x1_ASAP7_75t_R.glb"
      alt="NAND gate standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 2.5m"
      field-of-view="30deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/asap7/NAND2x1_ASAP7_75t_R.png"
          alt="NAND gate standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="https://media.abapages.com/course-site/asap7/NAND2x1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>NAND gate (NAND2x1)</figcaption>
  </figure>

  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="https://media.abapages.com/course-site/asap7/AOI211x1_ASAP7_75t_R.glb"
      alt="And-or-invert standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 1.5m"
      field-of-view="30deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/asap7/AOI211x1_ASAP7_75t_R.png"
          alt="And-or-invert standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="https://media.abapages.com/course-site/asap7/AOI211x1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>AND-OR-INVERT (AOI211x1)</figcaption>
  </figure>

  <figure class="week1-cell-card">
    <model-viewer
      class="week1-cell-viewer"
      src="https://media.abapages.com/course-site/asap7/DFFHQNx1_ASAP7_75t_R.glb"
      alt="D flip-flop standard cell in ASAP7 visualized in 3D"
      orientation="135deg 0deg 0deg"
      camera-controls
      camera-target="0m 0m 0m"
      camera-orbit="0deg 150deg 1.5m"
      field-of-view="30deg"
      interaction-prompt="when-focused"
      touch-action="pan-y"
      shadow-intensity="1"
      exposure="0.85"
      tone-mapping="commerce"
      environment-image="neutral"
      transparent-background
      ar-status="not-presenting"
      loading="eager"
    >
      <div class="hero-model-fallback" hidden>
        <img
          class="hero-model-fallback-image"
          src="https://media.abapages.com/course-site/asap7/DFFHQNx1_ASAP7_75t_R.png"
          alt="D flip-flop standard cell in ASAP7"
          loading="lazy"
        />
        <p>
          Interactive 3D preview unavailable in this browser.
          <a href="https://media.abapages.com/course-site/asap7/DFFHQNx1_ASAP7_75t_R.glb">Open the GLB file directly.</a>
        </p>
      </div>
    </model-viewer>
    <figcaption>D Flip-Flop (DFFHQNx1)</figcaption>
  </figure>
</section>
```

## ASAP7

```{raw} html
<section class="pdk-panel" data-pdk="asap7" data-default-model="NAND2x2_ASAP7_75t_R">
  <div class="pdk-controls">
    <label class="pdk-label" for="pdk-select-asap7">Choose a cell to view in 3D</label>
    <select id="pdk-select-asap7" class="pdk-select">
      <option value="NAND2x2_ASAP7_75t_R" selected>NAND2x2_ASAP7_75t_R</option>
    </select>
  </div>

  <model-viewer
    class="pdk-viewer"
    src="https://media.abapages.com/course-site/asap7/NAND2x2_ASAP7_75t_R.glb"
    alt="asap7 standard cell NAND2x2 visualized in 3D"
    orientation="135deg 0deg 0deg"
    camera-controls
    camera-target="0m 0m 0m"
    camera-orbit="0deg 150deg 2m"
    field-of-view="30deg"
    interaction-prompt="when-focused"
    touch-action="pan-y"
    shadow-intensity="1"
    exposure="0.85"
    tone-mapping="commerce"
    environment-image="neutral"
    transparent-background
    ar-status="not-presenting"
    loading="eager"
  >
    <div class="hero-model-fallback" hidden>
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/asap7/NAND2x2_ASAP7_75t_R.png"
        alt="asap7 standard cell NAND2x2"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a class="pdk-glb-link" href="https://media.abapages.com/course-site/asap7/NAND2x2_ASAP7_75t_R.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
</section>
```

## NanGate45

```{raw} html
<section class="pdk-panel" data-pdk="nangate45" data-default-model="NAND2_X2">
  <div class="pdk-controls">
    <label class="pdk-label" for="pdk-select-nangate45">Choose a cell to view in 3D</label>
    <select id="pdk-select-nangate45" class="pdk-select">
      <option value="NAND2_X2" selected>NAND2_X2</option>
    </select>
  </div>

  <model-viewer
    class="pdk-viewer"
    src="https://media.abapages.com/course-site/nangate45/NAND2_X2.glb"
    alt="nangate45 standard cell NAND2_X2 visualized in 3D"
    orientation="135deg 0deg 0deg"
    camera-controls
    camera-target="0m 0m 0m"
    camera-orbit="0deg 150deg 2m"
    field-of-view="30deg"
    interaction-prompt="when-focused"
    touch-action="pan-y"
    shadow-intensity="1"
    exposure="0.85"
    tone-mapping="commerce"
    environment-image="neutral"
    transparent-background
    ar-status="not-presenting"
    loading="eager"
  >
    <div class="hero-model-fallback" hidden>
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/nangate45/NAND2_X2.png"
        alt="nangate45 standard cell NAND2_X2"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a class="pdk-glb-link" href="https://media.abapages.com/course-site/nangate45/NAND2_X2.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
</section>
```

## Sky130

```{raw} html
<section class="pdk-panel" data-pdk="sky130" data-default-model="sky130_fd_sc_hd__nand2_2">
  <div class="pdk-controls">
    <label class="pdk-label" for="pdk-select-sky130">Choose a cell to view in 3D</label>
    <select id="pdk-select-sky130" class="pdk-select">
      <option value="sky130_fd_sc_hd__nand2_2" selected>sky130_fd_sc_hd__nand2_2</option>
    </select>
  </div>

  <model-viewer
    class="pdk-viewer"
    src="https://media.abapages.com/course-site/sky130/sky130_fd_sc_hd__nand2_2.glb"
    alt="sky130 standard cell nand2_2 visualized in 3D"
    orientation="135deg 0deg 0deg"
    camera-controls
    camera-target="0m 0m 0m"
    camera-orbit="0deg 150deg 2m"
    field-of-view="30deg"
    interaction-prompt="when-focused"
    touch-action="pan-y"
    shadow-intensity="1"
    exposure="0.85"
    tone-mapping="commerce"
    environment-image="neutral"
    transparent-background
    ar-status="not-presenting"
    loading="eager"
  >
    <div class="hero-model-fallback" hidden>
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/sky130/sky130_fd_sc_hd__nand2_2.png"
        alt="sky130 standard cell nand2_2"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a class="pdk-glb-link" href="https://media.abapages.com/course-site/sky130/sky130_fd_sc_hd__nand2_2.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
</section>
```

## Sky130HD

```{raw} html
<section class="pdk-panel" data-pdk="sky130hd" data-default-model="sky130_fd_sc_hd__nand2_2">
  <div class="pdk-controls">
    <label class="pdk-label" for="pdk-select-sky130hd">Choose a cell to view in 3D</label>
    <select id="pdk-select-sky130hd" class="pdk-select">
      <option value="sky130_fd_sc_hd__nand2_2" selected>sky130_fd_sc_hd__nand2_2</option>
    </select>
  </div>

  <model-viewer
    class="pdk-viewer"
    src="https://media.abapages.com/course-site/sky130hd/sky130_fd_sc_hd__nand2_2.glb"
    alt="sky130hd standard cell nand2_2 visualized in 3D"
    orientation="135deg 0deg 0deg"
    camera-controls
    camera-target="0m 0m 0m"
    camera-orbit="0deg 150deg 2m"
    field-of-view="30deg"
    interaction-prompt="when-focused"
    touch-action="pan-y"
    shadow-intensity="1"
    exposure="0.85"
    tone-mapping="commerce"
    environment-image="neutral"
    transparent-background
    ar-status="not-presenting"
    loading="eager"
  >
    <div class="hero-model-fallback" hidden>
      <img
        class="hero-model-fallback-image"
        src="https://media.abapages.com/course-site/sky130hd/sky130_fd_sc_hd__nand2_2.png"
        alt="sky130hd standard cell nand2_2"
        loading="lazy"
      />
      <p>
        Interactive 3D preview unavailable in this browser.
        <a class="pdk-glb-link" href="https://media.abapages.com/course-site/sky130hd/sky130_fd_sc_hd__nand2_2.glb">Open the GLB file directly.</a>
      </p>
    </div>
  </model-viewer>
</section>

<script>
  (function () {
    var mediaBase = "https://media.abapages.com/course-site";
    var manifestUrl = "_static/3d-cell-manifest.json";

    function commonPrefix(items) {
      if (!items.length) return "";
      var prefix = items[0];
      for (var i = 1; i < items.length; i += 1) {
        while (items[i].indexOf(prefix) !== 0 && prefix) {
          prefix = prefix.slice(0, -1);
        }
        if (!prefix) break;
      }
      return prefix;
    }

    function commonSuffix(items) {
      if (!items.length) return "";
      var rev = items.map(function (item) {
        return item.split("").reverse().join("");
      });
      return commonPrefix(rev).split("").reverse().join("");
    }

    function computeCommonParts(models) {
      var prefix = commonPrefix(models);
      var suffix = commonSuffix(models);

      if (prefix.length < 4) {
        prefix = "";
      }
      if (suffix.length < 4) {
        suffix = "";
      }

      return { prefix: prefix, suffix: suffix };
    }

    function displayLabel(modelName, commonParts) {
      var label = modelName;
      var prefix = commonParts && commonParts.prefix ? commonParts.prefix : "";
      var suffix = commonParts && commonParts.suffix ? commonParts.suffix : "";

      if (prefix && label.indexOf(prefix) === 0) {
        label = label.slice(prefix.length);
      }
      if (suffix && label.endsWith(suffix)) {
        label = label.slice(0, -suffix.length);
      }

      label = label.replace(/^_+|_+$/g, "");
      return label || modelName;
    }

    function pickDefaultModel(models, requestedDefault) {
      if (requestedDefault && models.indexOf(requestedDefault) >= 0) {
        return requestedDefault;
      }

      var nand2x2Like = models.find(function (name) {
        var s = name.toLowerCase();
        return s.indexOf("nand2x2") >= 0 || s.indexOf("nand2_x2") >= 0 || s.indexOf("nand2_2") >= 0;
      });
      if (nand2x2Like) {
        return nand2x2Like;
      }

      var nand2Like = models.find(function (name) {
        return name.toLowerCase().indexOf("nand2") >= 0;
      });
      if (nand2Like) {
        return nand2Like;
      }

      return models[0] || requestedDefault || "";
    }

    function populateSelect(select, models, defaultModel, commonParts) {
      select.innerHTML = "";

      models.forEach(function (model) {
        var option = document.createElement("option");
        option.value = model;
        option.textContent = displayLabel(model, commonParts);
        if (model === defaultModel) {
          option.selected = true;
        }
        select.appendChild(option);
      });
    }

    function setPanelModel(panel, modelName) {
      var pdk = panel.getAttribute("data-pdk");
      if (!pdk || !modelName) return;

      var glbUrl = mediaBase + "/" + pdk + "/" + modelName + ".glb";
      var pngUrl = mediaBase + "/" + pdk + "/" + modelName + ".png";

      var viewer = panel.querySelector("model-viewer");
      if (viewer) {
        viewer.setAttribute("src", glbUrl);
        viewer.setAttribute("alt", pdk + " standard cell " + modelName + " visualized in 3D");
      }

      panel.querySelectorAll(".hero-model-fallback-image").forEach(function (img) {
        img.setAttribute("src", pngUrl);
        img.setAttribute("alt", pdk + " standard cell " + modelName);
      });

      panel.querySelectorAll(".pdk-glb-link").forEach(function (link) {
        link.setAttribute("href", glbUrl);
      });
    }

    fetch(manifestUrl)
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Could not load cell manifest");
        }
        return response.json();
      })
      .then(function (manifest) {
        document.querySelectorAll(".pdk-panel").forEach(function (panel) {
          var pdk = panel.getAttribute("data-pdk");
          var select = panel.querySelector(".pdk-select");
          if (!select || !pdk) return;

          var models = Array.isArray(manifest[pdk]) ? manifest[pdk] : [];
          if (!models.length) {
            return;
          }

          var defaultModel = pickDefaultModel(models, panel.getAttribute("data-default-model"));
          var commonParts = computeCommonParts(models);
          populateSelect(select, models, defaultModel, commonParts);

          select.addEventListener("change", function () {
            setPanelModel(panel, select.value);
          });

          setPanelModel(panel, defaultModel);
        });
      })
      .catch(function () {
        document.querySelectorAll(".pdk-panel").forEach(function (panel) {
          var select = panel.querySelector(".pdk-select");
          if (!select) return;
          setPanelModel(panel, select.value || panel.getAttribute("data-default-model"));
        });
      });
  })();
</script>
```