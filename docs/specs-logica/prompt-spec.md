# Task: Generate Comprehensive Feature Specification

## Context
Create a detailed technical specification for [FEATURE_NAME] by thoroughly analyzing:
- The reference implementation in [REFERENCE_FILE] (use as inspiration, not limitation)
- All documentation in [DOCS_PATH]
- Any other relevant project files and patterns

## Core Requirements

### 1. Standards & Conventions
- Follow ALL established project steering rules and coding standards
- Maintain consistency with existing architectural patterns
- Adhere to naming conventions and project structure

### 2. Language
- **The specification MUST be written in ENGLISH**

### 3. UI Integration (Critical)
- The UI is already implemented and matches the Figma design exactly
- **DO NOT modify, suggest changes to, or recreate any UI components**
- Focus exclusively on business logic, state management, and data flow
- Ensure the logic integrates seamlessly with existing UI structure
- The UI is the consumer of your logic - design accordingly

### 4. Logic Development (Primary Focus)
- Develop complete, production-ready business logic
- Include all edge cases and error handling
- Never use Models, Repository or Services
- Specify state management approach
- Document API calls and data transformations
- Consider performance implications

## Success Criteria
- Logic is fully functional and complete
- Seamless integration with existing UI
- Follows all project standards
- Handles all edge cases
- Clear, implementable specification

## Avoid vague requirements like:
- "System should handle file uploads efficiently"

---

**Remember**: The reference file [REFERENCE_FILE] is a guide for understanding patterns, not a limitation. Feel free to create more sophisticated, robust solutions while maintaining consistency with project standards.