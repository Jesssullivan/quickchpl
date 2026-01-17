// quickchpl Documentation Custom JavaScript

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', function() {
  // Add copy buttons to code blocks (if not already handled by Material)
  initCodeCopy();

  // Add anchor links to headings
  initAnchorLinks();
});

// Copy code functionality
function initCodeCopy() {
  const codeBlocks = document.querySelectorAll('pre code');

  codeBlocks.forEach(function(codeBlock) {
    // Skip if already has copy button
    if (codeBlock.parentElement.querySelector('.copy-button')) return;

    const button = document.createElement('button');
    button.className = 'copy-button';
    button.textContent = 'Copy';
    button.setAttribute('aria-label', 'Copy code to clipboard');

    button.addEventListener('click', function() {
      const code = codeBlock.textContent;
      navigator.clipboard.writeText(code).then(function() {
        button.textContent = 'Copied!';
        setTimeout(function() {
          button.textContent = 'Copy';
        }, 2000);
      }).catch(function(err) {
        console.error('Failed to copy:', err);
      });
    });

    codeBlock.parentElement.style.position = 'relative';
    codeBlock.parentElement.appendChild(button);
  });
}

// Anchor links for headings
function initAnchorLinks() {
  const headings = document.querySelectorAll('h2[id], h3[id], h4[id]');

  headings.forEach(function(heading) {
    // Skip if already has anchor
    if (heading.querySelector('.anchor-link')) return;

    const link = document.createElement('a');
    link.className = 'anchor-link';
    link.href = '#' + heading.id;
    link.textContent = '#';
    link.setAttribute('aria-label', 'Link to this section');

    heading.appendChild(link);
  });
}

// Chapel syntax highlighting registration (for Prism if used)
if (typeof Prism !== 'undefined') {
  Prism.languages.chapel = {
    'comment': [
      {
        pattern: /\/\*[\s\S]*?\*\//,
        greedy: true
      },
      {
        pattern: /\/\/.*/,
        greedy: true
      }
    ],
    'string': {
      pattern: /"(?:[^"\\]|\\.)*"/,
      greedy: true
    },
    'keyword': /\b(?:bool|break|by|class|cobegin|coforall|config|const|continue|do|domain|else|enum|export|extern|false|for|forall|if|import|in|index|inline|inout|iter|label|lambda|let|locale|module|new|nil|on|otherwise|out|param|private|proc|public|range|record|reduce|ref|require|return|scan|select|serial|single|sparse|subdomain|sync|then|this|throw|throws|true|try|type|union|use|var|when|where|while|with|yield|zip)\b/,
    'builtin': /\b(?:int|uint|real|imag|complex|bool|string|bytes|nothing|void|borrowed|owned|shared|unmanaged)\b/,
    'number': /\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?\b/,
    'operator': /[+\-*/%&|^~<>=!?:]+/,
    'punctuation': /[{}[\]();,.]/
  };
}

// Console log for debugging
console.log('quickchpl docs loaded');
